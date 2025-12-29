package pdf

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"

	"github.com/ledongthuc/pdf"
	"github.com/pdfcpu/pdfcpu/pkg/api"
)

// TOCParser defines an interface for identifying sections.
// It matches the signature of llm.Client.IdentifySections.
type TOCParser interface {
	IdentifySections(tocText string) (map[string]int, error)
}

// ParseTOC scans the first 20 pages (or fewer) and uses the provided parser (LLM) to identify sections.
func ParseTOC(filePath string, parser TOCParser) (map[string]int, error) {
	f, r, err := pdf.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	// Extract text from first 20 pages
	var tocTextBuilder strings.Builder
	tocMaxPages := 20
	if r.NumPage() < tocMaxPages {
		tocMaxPages = r.NumPage()
	}

	for pageIndex := 1; pageIndex <= tocMaxPages; pageIndex++ {
		p := r.Page(pageIndex)
		if p.V.IsNull() {
			continue
		}

		content, err := p.GetPlainText(nil)
		if err != nil {
			continue
		}
		tocTextBuilder.WriteString(content)
		tocTextBuilder.WriteString("\n")
	}

	fullText := tocTextBuilder.String()
	if strings.TrimSpace(fullText) == "" {
		return nil, fmt.Errorf("no text found in first %d pages", tocMaxPages)
	}

	// Use LLM to parse
	return parser.IdentifySections(fullText)
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
