package typst

import (
	"intDocument/server/database"
)

func makeTestDetails(id string, documentName string, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) (string, bool) {

	content := `
	= Test Details
	`

	errMsg, tm, ok := database.GetContent(documentName, "TestMatrix")
	if !ok {
		content = content + "Error in Cehckout Interface: " + errMsg
	}
	tmContent := makeTestMatrix(id, tm, imageAdder, pdfAdder, tableAdder)
	content = content + tmContent

	errMsg, tp, ok := database.GetContent(documentName, "TestPlans")
	if !ok {
		content = content + "Error in Specific Requirements: " + errMsg
	}
	tpContent := makeTestPlan(id, tp, imageAdder, pdfAdder, tableAdder)
	content = content + tpContent

	errMsg, procedures, ok := database.GetContent(documentName, "TestProcedures")
	if !ok {
		content = content + "Error in Safety Requirements: " + errMsg
	}
	procContent := makeProcedures(id, procedures, imageAdder, pdfAdder, tableAdder)

	content = content + procContent + "\n\n"

	content = content + "#pagebreak()"

	return content, true
}

func makeTestMatrix(id string, tm database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := `
	== Test Matrix
	`
	tmContent := addContent(id, tm, imageAdder, pdfAdder, tableAdder)
	content = content + tmContent
	return content
}

func makeTestPlan(id string, tp database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := `
	== Test Plan
	`
	tpContent := addContent(id, tp, imageAdder, pdfAdder, tableAdder)
	content = content + tpContent
	return content
}

func makeProcedures(id string, tp database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := "#pagebreak()" + "\n"
	content = content + `
	== Test Procedures
	#set block(spacing:1.2em)
	#set par(leading:0.65em)
	`
	var proceduresTable string
	proceduresTable = "Title, Procedure\n"
	for i := 0; i < tp.NoOfItems; i++ {
		proceduresTable = proceduresTable + tp.Captions[i] + "," + tp.FileName[i] + "\n"
	}
	tableId := tableAdder()
	procTable := addTable(proceduresTable, "Procedure List", false, tableId)
	content = content + procTable + "\n\n"
	procedures := addContent(id, tp, imageAdder, pdfAdder, tableAdder)
	content = content + procedures
	content = content + `
	#set block(spacing:1.5em)
	#set par(leading:1.15em)
	`
	return content
}
