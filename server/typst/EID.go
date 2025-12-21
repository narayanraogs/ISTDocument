package typst

import (
	"intDocument/server/database"
)

func makeEID(id string, documentName string, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) (string, bool) {
	content := `
	= EID
	`

	errMsg, eid, ok := database.GetContent(documentName, "Annexure-EID")
	if !ok {
		content = content + "Error in getting EID: " + errMsg
		return "", false
	}
	eidContent := addContent(id, eid, imageAdder, pdfAdder, tableAdder)
	content = content + eidContent + "\n\n"
	content = content + "#pagebreak()"

	return content, true
}
