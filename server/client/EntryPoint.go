package client

import (
	"encoding/base64"
	"fmt"
	"intDocument/server/config"
	"intDocument/server/database"
	"intDocument/server/typst"

	"io/fs"
	"net/http"
	"slices"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func Listen(web fs.FS, port string) {
	r := gin.Default()

	r.Use(cors.New(cors.Config{
		AllowOrigins: []string{"*"},
		AllowMethods: []string{"*"},
		AllowHeaders: []string{"*"},
		MaxAge:       24 * time.Hour,
	}))

	r.POST("/getAllDocumentNames", getAllDocumentNames)
	r.POST("/addDocument", addDocument)
	r.POST("/getDocumentDetails", getDocumentDetails)
	r.POST("/addDocumentDetails", addDocumentDetails)
	r.POST("/getSubsystemDetails", getSubsystemDetails)
	r.POST("/addSubsystemDetails", addSubsystemDetails)
	r.POST("/getContent", getContent)
	r.POST("/addContent", addContent)
	r.POST("/copyDocument", copyDocument)
	r.POST("/deleteDocument", deleteDocument)

	r.POST("/compileDocument", compileDocument)
	r.POST("/getSignaturePage", getSignaturePage)

	// Use NoRoute to serve static files to avoid conflict with API
	r.NoRoute(func(c *gin.Context) {
		path := c.Request.URL.Path
		// Remove leading slash for checking in fs.FS
		name := strings.TrimPrefix(path, "/")
		if name == "" {
			name = "index.html"
		}

		// Try to open the file to check existence
		f, err := web.Open(name)
		if err != nil {
			// File not found -> serve index.html (SPA support)
			c.FileFromFS("/", http.FS(web))
			return
		}
		f.Close()

		// File found -> serve it
		c.FileFromFS(path, http.FS(web))
	})

	err := r.Run(":" + port)
	if err != nil {
		fmt.Println("Cannot listen on " + port)
		return
	}
}

func getAllDocumentNames(c *gin.Context) {
	var clientID ClientID
	var names DocumentNamesResponse
	names.DocumentNames = make([]string, 0)
	if err := c.BindJSON(&clientID); err != nil {
		names.OK = false
		names.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, names)
		return
	}
	fmt.Println("Request ", clientID)
	docNames, ok := database.GetAllDocumentNames()
	if !ok {
		names.OK = false
		names.Message = "Unable to Get Document Names"
		c.IndentedJSON(http.StatusOK, names)
		return
	}
	slices.Sort(docNames)
	names.DocumentNames = docNames
	names.OK = true
	names.Message = "Database Registered"
	c.IndentedJSON(http.StatusOK, names)
}

func addDocument(c *gin.Context) {
	var addDocument AddDocument
	var ack Ack
	if err := c.BindJSON(&addDocument); err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	fmt.Println("Request", addDocument)
	msg, ok := database.AddDocument(addDocument.Name)
	if !ok {
		ack.OK = false
		ack.Message = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	ack.OK = true
	ack.Message = "Document Added"
	c.IndentedJSON(http.StatusOK, ack)
}

func getDocumentDetails(c *gin.Context) {
	var addDocument AddDocument
	var details DocumentDetails
	if err := c.BindJSON(&addDocument); err != nil {
		details.OK = false
		details.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, details)
		return
	}
	fmt.Println("Request", addDocument)
	msg, detailsDB, ok := database.GetDocumentDetails(addDocument.Name)
	if !ok {
		details.OK = false
		details.Message = msg
		c.IndentedJSON(http.StatusOK, details)
		return
	}
	details.OK = true
	details.Message = "Document Added"
	details.DocumentNumber = detailsDB.DocumentNumber
	details.PreparedBy = detailsDB.PreparedBy
	details.ReviewedByName = detailsDB.ReviewedByName
	details.ReviewedByTitle = detailsDB.ReviewedByTitle
	details.FirstApproverName = detailsDB.FirstApproverName
	details.FirstApproverTitle = detailsDB.FirstApproverTitle
	details.SecondApproverName = detailsDB.SecondApproverName
	details.SecondApproverTitle = detailsDB.SecondApproverTitle
	details.EID = detailsDB.EID
	details.ResultFormat = detailsDB.ResultFormat

	c.IndentedJSON(http.StatusOK, details)
}

func addDocumentDetails(c *gin.Context) {
	var request DocumentDetailsRequest
	var ack Ack
	if err := c.BindJSON(&request); err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	fmt.Println("Request", request.ID, request.DocumentName)
	var details database.DocumentDetails
	details.DocumentNumber = request.DocumentNumber
	details.PreparedBy = request.PreparedBy
	details.ReviewedByName = request.ReviewedByName
	details.ReviewedByTitle = request.ReviewedByTitle
	details.FirstApproverName = request.FirstApproverName
	details.FirstApproverTitle = request.FirstApproverTitle
	details.SecondApproverName = request.SecondApproverName
	details.SecondApproverTitle = request.SecondApproverTitle
	details.EID = request.EID
	details.ResultFormat = request.ResultFormat

	msg, ok := database.AddDocumentDetails(request.DocumentName, details)
	if !ok {
		ack.OK = false
		ack.Message = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	ack.OK = true
	ack.Message = "Document Details Added"
	c.IndentedJSON(http.StatusOK, ack)
}

func addSubsystemDetails(c *gin.Context) {
	var request SubsystemDetailsRequest
	var ack Ack
	if err := c.BindJSON(&request); err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	fmt.Println("Request", request.ID, request.DocumentName)
	var details database.SubsystemDetails
	details.SubsystemName = request.SubsystemName
	details.SatelliteName = request.SatelliteName
	details.SatelliteClass = request.SatelliteClass
	details.SatelliteImage = request.SatelliteImage

	msg, ok := database.AddSubsystemDetails(request.DocumentName, details)
	if !ok {
		ack.OK = false
		ack.Message = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	ack.OK = true
	ack.Message = "Subsystem Details Added"
	c.IndentedJSON(http.StatusOK, ack)
}

func getSubsystemDetails(c *gin.Context) {
	var addDocument AddDocument
	var details SubsystemDetails
	if err := c.BindJSON(&addDocument); err != nil {
		details.OK = false
		details.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, details)
		return
	}
	fmt.Println("Request", addDocument.ID, addDocument.Name)
	msg, detailsDB, ok := database.GetSubsystemDetails(addDocument.Name)
	if !ok {
		details.OK = false
		details.Message = msg
		c.IndentedJSON(http.StatusOK, details)
		return
	}
	details.OK = true
	details.Message = "Document Added"
	details.SatelliteClass = detailsDB.SatelliteClass
	details.SatelliteName = detailsDB.SatelliteName
	details.SubsystemName = detailsDB.SubsystemName
	details.SatelliteImage = detailsDB.SatelliteImage
	c.IndentedJSON(http.StatusOK, details)
}

func getContent(c *gin.Context) {
	var contentRequest ContentRequest
	var response ContentResponse
	response.ContentType = make([]string, 0)
	response.FileName = make([]string, 0)
	response.Value = make([]string, 0)
	response.Captions = make([]string, 0)
	response.Landscape = make([]bool, 0)
	if err := c.BindJSON(&contentRequest); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	fmt.Println("Request", contentRequest.ID, contentRequest.DocumentName, contentRequest.Subsection)
	msg, contentDB, ok := database.GetContent(contentRequest.DocumentName, contentRequest.Subsection)
	if !ok {
		response.OK = false
		response.Message = msg
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	response.OK = true
	response.Message = "Content Retrived"
	response.NoOfItems = contentDB.NoOfItems
	response.ContentType = append(response.ContentType, contentDB.ContentType...)
	response.FileName = append(response.FileName, contentDB.FileName...)
	response.Value = append(response.Value, contentDB.Value...)
	response.Captions = append(response.Captions, contentDB.Captions...)
	response.Landscape = append(response.Landscape, contentDB.Landscape...)
	c.IndentedJSON(http.StatusOK, response)
}

func addContent(c *gin.Context) {
	var contentRequest AddContentRequest
	var ack Ack
	if err := c.BindJSON(&contentRequest); err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	fmt.Println("Request", contentRequest.ID, contentRequest.DocumentName, contentRequest.Subsection)
	var content database.Content
	content.ContentType = make([]string, 0)
	content.Value = make([]string, 0)
	content.FileName = make([]string, 0)
	content.Captions = make([]string, 0)
	content.Landscape = make([]bool, 0)

	content.NoOfItems = contentRequest.NoOfItems
	content.ContentType = append(content.ContentType, contentRequest.ContentType...)
	content.Value = append(content.Value, contentRequest.Value...)
	content.FileName = append(content.FileName, contentRequest.FileName...)
	content.Captions = append(content.Captions, contentRequest.Captions...)
	content.Landscape = append(content.Landscape, contentRequest.Landscape...)

	msg, ok := database.AddContent(contentRequest.DocumentName, contentRequest.Subsection, content)
	if !ok {
		ack.OK = false
		ack.Message = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	ack.OK = true
	ack.Message = "Content Added"
	c.IndentedJSON(http.StatusOK, ack)
}

func copyDocument(c *gin.Context) {
	var copyDocument CopyDocument
	var ack Ack
	if err := c.BindJSON(&copyDocument); err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	fmt.Println("Request", copyDocument)
	msg, ok := database.CopyDocument(copyDocument.OldName, copyDocument.NewName)
	if !ok {
		ack.OK = false
		ack.Message = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	ack.OK = true
	ack.Message = "Document Added"
	c.IndentedJSON(http.StatusOK, ack)
}

type DeleteDocumentRequest struct {
	Name     string `json:"Name"`
	Password string `json:"Password"`
}

func deleteDocument(c *gin.Context) {
	var deleteRequest DeleteDocumentRequest
	var ack Ack
	if err := c.BindJSON(&deleteRequest); err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	fmt.Println("Request Delete", deleteRequest.Name)

	if deleteRequest.Password != config.Config.DeletePassword {
		ack.OK = false
		ack.Message = "Invalid Password"
		c.IndentedJSON(http.StatusOK, ack)
		return
	}

	msg, ok := database.DeleteDocument(deleteRequest.Name)
	if !ok {
		ack.OK = false
		ack.Message = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	ack.OK = true
	ack.Message = "Document Deleted"
	c.IndentedJSON(http.StatusOK, ack)
}

func compileDocument(c *gin.Context) {
	var addDocument AddDocument
	var ack PDFResponse
	if err := c.BindJSON(&addDocument); err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	fmt.Println("Request", addDocument)
	msg, ok := typst.InitializeNewDocument(addDocument.ID, addDocument.Name)
	if !ok {
		ack.OK = false
		ack.Message = msg
		ack.Content = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	data, ok := typst.Compile(addDocument.ID)
	ack.Content = base64.StdEncoding.EncodeToString(data)
	if !ok {
		ack.OK = false
		ack.Message = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	ack.OK = true
	ack.Message = "Compilation Successful"
	c.IndentedJSON(http.StatusOK, ack)
}

func getSignaturePage(c *gin.Context) {
	var addDocument AddDocument
	var ack PDFResponse
	if err := c.BindJSON(&addDocument); err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	fmt.Println("Request", addDocument)
	msg, ok := typst.GetSignaturePage(addDocument.ID, addDocument.Name)
	if !ok {
		ack.OK = false
		ack.Message = msg
		ack.Content = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	data, ok := typst.Compile(addDocument.ID)
	ack.Content = base64.StdEncoding.EncodeToString(data)
	if !ok {
		ack.OK = false
		ack.Message = msg
		c.IndentedJSON(http.StatusOK, ack)
		return
	}
	ack.OK = true
	ack.Message = "Compilation Successful"
	c.IndentedJSON(http.StatusOK, ack)
}
