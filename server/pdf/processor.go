package pdf

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"

	"github.com/ledongthuc/pdf"
	"github.com/pdfcpu/pdfcpu/pkg/api"
)

// ParseTOC scans the first few pages to find key sections.
// Returns a map of Section Name -> Page Number.
func ParseTOC(filePath string) (map[string]int, error) {
	f, r, err := pdf.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	sections := make(map[string]int)
	tocMaxPages := 10 // Assumption: TOC is within first 10 pages
	if r.NumPage() < tocMaxPages {
		tocMaxPages = r.NumPage()
	}

	// Simple regex to find lines like "1. Introduction ....... 5" or "Introduction 5"
	// This is brittle and might need the LLM fallback.
	re := regexp.MustCompile(`(?i)(introduction|specifications|block diagram).*?(\d+)$`)

	for pageIndex := 1; pageIndex <= tocMaxPages; pageIndex++ {
		p := r.Page(pageIndex)
		if p.V.IsNull() {
			continue
		}

		content, err := p.GetPlainText(nil)
		if err != nil {
			continue
		}

		lines := strings.Split(content, "\n")
		for _, line := range lines {
			line = strings.TrimSpace(line)
			matches := re.FindStringSubmatch(line)
			if len(matches) == 3 {
				sectionName := strings.ToLower(matches[1])
				pageStr := matches[2]
				page, err := strconv.Atoi(pageStr)
				if err == nil {
					// Map recognized keys to standard keys
					if strings.Contains(sectionName, "introduction") {
						sections["Introduction"] = page
					} else if strings.Contains(sectionName, "specifications") {
						sections["Specifications"] = page
					} else if strings.Contains(sectionName, "block diagram") {
						sections["Block Diagram"] = page
					}
				}
			}
		}
	}
	return sections, nil
}

// ExtractText extracts plain text from a specific page.
func ExtractText(filePath string, pageNum int) (string, error) {
	f, r, err := pdf.Open(filePath)
	if err != nil {
		return "", err
	}
	defer f.Close()

	if pageNum > r.NumPage() || pageNum < 1 {
		return "", fmt.Errorf("page number %d out of bounds", pageNum)
	}

	p := r.Page(pageNum)
	if p.V.IsNull() {
		return "", nil
	}

	return p.GetPlainText(nil)
}

// ExtractImages extracts images from a specific page to a temp directory.
// Returns a list of file paths to the extracted images.
func ExtractImages(filePath string, pageNum int, outputDir string) ([]string, error) {
	// pdfcpu extract images
	// api.ExtractImagesFile(inFile, outDir, selectedPages, conf)

	// Create output directory if it doesn't exist
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return nil, err
	}

	selectedPages := []string{strconv.Itoa(pageNum)}
	err := api.ExtractImagesFile(filePath, outputDir, selectedPages, nil)
	if err != nil {
		return nil, err
	}

	// Find extracted files
	files, err := os.ReadDir(outputDir)
	if err != nil {
		return nil, err
	}

	var imagePaths []string
	for _, file := range files {
		if !file.IsDir() {
			imagePaths = append(imagePaths, filepath.Join(outputDir, file.Name()))
		}
	}

	// Sort to ensure deterministic order (though pdfcpu naming is usually predictable)
	sort.Strings(imagePaths)

	return imagePaths, nil
}

// GetLargestImage identifies the largest image file in the list (by file size).
// This is a heuristic to find the main diagram vs icons/logos.
func GetLargestImage(imagePaths []string) (string, error) {
	var largestFile string
	var maxSizeBytes int64

	for _, path := range imagePaths {
		info, err := os.Stat(path)
		if err != nil {
			continue
		}
		if info.Size() > maxSizeBytes {
			maxSizeBytes = info.Size()
			largestFile = path
		}
	}

	if largestFile == "" {
		return "", fmt.Errorf("no images found")
	}
	return largestFile, nil
}

// Helper to check if file is PDF
func IsPDF(filename string) bool {
    return strings.HasSuffix(strings.ToLower(filename), ".pdf")
}
