package handlers

import (
	"encoding/base64"
	"fmt"
	"intDocument/server/database"
	"intDocument/server/llm"
	"intDocument/server/pdf"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type ProcessDocResponse struct {
	OK      bool   `json:"ok"`
	Message string `json:"message"`
}

func ProcessDesignDoc(c *gin.Context) {
	var response ProcessDocResponse

	// 1. Get Document ID and File
	docID := c.PostForm("id")
	if docID == "" {
		response.OK = false
		response.Message = "Missing Document ID"
		c.IndentedJSON(http.StatusBadRequest, response)
		return
	}

	documentName := c.PostForm("name")
	if documentName == "" {
		response.OK = false
		response.Message = "Missing Document Name"
		c.IndentedJSON(http.StatusBadRequest, response)
		return
	}

	file, err := c.FormFile("file")
	if err != nil {
		response.OK = false
		response.Message = "Missing PDF File"
		c.IndentedJSON(http.StatusBadRequest, response)
		return
	}

	// 2. Save PDF to Temp File
	tempDir := filepath.Join(os.TempDir(), "istdoc_"+docID)
	os.MkdirAll(tempDir, 0755)
	defer os.RemoveAll(tempDir) // Cleanup

	tempFilePath := filepath.Join(tempDir, "uploaded.pdf")
	if err := c.SaveUploadedFile(file, tempFilePath); err != nil {
		response.OK = false
		response.Message = "Failed to save uploaded file: " + err.Error()
		c.IndentedJSON(http.StatusInternalServerError, response)
		return
	}

	// 3. Parse TOC
	sections, err := pdf.ParseTOC(tempFilePath)
	if err != nil {
		response.OK = false
		response.Message = "Failed to parse TOC (Index): " + err.Error()
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	fmt.Printf("Found Sections: %+v\n", sections)

	if len(sections) == 0 {
		response.OK = false
		response.Message = "No relevant sections (Introduction, Specifications, Block Diagram) found in the Index."
		c.IndentedJSON(http.StatusOK, response)
		return
	}

	llmClient := llm.NewOllamaClient()
	var processErrors []string
	var successCount int

	// 4. Process Introduction
	if page, ok := sections["Introduction"]; ok {
		text, err := pdf.ExtractText(tempFilePath, page)
		if err == nil && text != "" {
			summary, err := llmClient.SummarizeText(text)
			if err == nil {
				var content database.Content
				content.NoOfItems = 1
				content.ContentType = []string{"Text"}
				content.Value = []string{summary}

				msg, ok := database.AddContent(documentName, "introduction", content)
				if !ok {
					processErrors = append(processErrors, "Failed to update Introduction DB: "+msg)
				} else {
					successCount++
				}
			} else {
				processErrors = append(processErrors, "Introduction Summarization failed: "+err.Error())
			}
		} else {
			processErrors = append(processErrors, "Failed to extract Introduction text.")
		}
	} else {
		processErrors = append(processErrors, "Introduction section not found in TOC.")
	}

	// 5. Process Specifications
	if page, ok := sections["Specifications"]; ok {
		text, err := pdf.ExtractText(tempFilePath, page)
		if err == nil && text != "" {
			specs, err := llmClient.ExtractSpecifications(text)
			if err == nil {
				msg, existingDetails, ok := database.GetSubsystemDetails(documentName)
				if !ok {
					// Even if get fails, we might want to overwrite or create new?
					// But usually Get fails if DB error. We'll init a empty struct if not found.
					// Note: database.GetSubsystemDetails returns msg, details, ok
					fmt.Println("GetSubsystemDetails Warning:", msg)
					existingDetails = database.SubsystemDetails{}
				}

				if val, ok := specs["Satellite Class"]; ok {
					existingDetails.SatelliteClass = val
				} else if val, ok := specs["Class"]; ok {
					existingDetails.SatelliteClass = val
				}

				if val, ok := specs["Subsystem Name"]; ok {
					existingDetails.SubsystemName = val
				}
				if val, ok := specs["Satellite Name"]; ok {
					existingDetails.SatelliteName = val
				}

				msg, ok = database.AddSubsystemDetails(documentName, existingDetails)
				if !ok {
					processErrors = append(processErrors, "Failed to update Subsystem DB: "+msg)
				} else {
					successCount++
				}
			} else {
				processErrors = append(processErrors, "Specification extraction failed: "+err.Error())
			}
		} else {
			processErrors = append(processErrors, "Failed to extract Specifications text.")
		}
	} else {
		processErrors = append(processErrors, "Specifications section not found in TOC.")
	}

	// 6. Process Block Diagram
	if page, ok := sections["Block Diagram"]; ok {
		images, err := pdf.ExtractImages(tempFilePath, page, filepath.Join(tempDir, "images"))
		if err == nil && len(images) > 0 {
			largestImg, err := pdf.GetLargestImage(images)
			if err == nil {
				imgBytes, err := os.ReadFile(largestImg)
				if err == nil {
					imgBase64 := base64.StdEncoding.EncodeToString(imgBytes)

					var content database.Content
					content.NoOfItems = 1
					content.ContentType = []string{"Image"}
					content.Value = []string{imgBase64}
					content.Captions = []string{"Block Diagram extracted from Design Document"}
					content.Landscape = []bool{false}

					msg, ok := database.AddContent(documentName, "block_diagram", content)
					if !ok {
						processErrors = append(processErrors, "Failed to add Block Diagram to DB: "+msg)
					} else {
						successCount++
					}
				} else {
					processErrors = append(processErrors, "Failed to read extracted image.")
				}
			} else {
				processErrors = append(processErrors, "Failed to identify largest image.")
			}
		} else {
			processErrors = append(processErrors, "No images found on Block Diagram page.")
		}
	} else {
		processErrors = append(processErrors, "Block Diagram section not found in TOC.")
	}

	response.OK = successCount > 0
	if successCount > 0 {
		response.Message = "Processing Complete. "
		if len(processErrors) > 0 {
			response.Message += "Warnings: " + fmt.Sprintf("%v", processErrors)
		}
	} else {
		response.Message = "Processing Failed. Errors: " + fmt.Sprintf("%v", processErrors)
	}

	c.IndentedJSON(http.StatusOK, response)
}
