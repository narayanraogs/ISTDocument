package typst

import (
	"intDocument/server/database"
)

func makeTestResults(id string, documentName string, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) (string, bool) {
	content := `
	= Test Result Format
	`

	errMsg, eid, ok := database.GetContent(documentName, "Annexure-TestResultsFormat")
	if !ok {
		content = content + "Error in getting Test Results Format: " + errMsg
		return "", false
	}
	trContent := addContent(id, eid, imageAdder, pdfAdder, tableAdder)
	content = content + trContent + "\n\n"
	content = content + "#pagebreak()"

	return content, true
}
