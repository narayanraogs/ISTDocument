package typst

import (
	"fmt"
	"intDocument/server/database"
	"os"
	"os/exec"
)

func InitializeNewDocument(id string, documentName string) (string, bool) {
	var document = database.DocumentDetails{}
	var subSystem = database.SubsystemDetails{}
	var ok bool
	var errMsg string
	errMsg, document, ok = database.GetDocumentDetails(documentName)
	if !ok {
		fmt.Println(errMsg)
		return "Document doesn't exist", false
	}
	errMsg, subSystem, ok = database.GetSubsystemDetails(documentName)
	if !ok {
		fmt.Println(errMsg)
		return "Document doesn't exist", false
	}
	err := os.MkdirAll(id, os.ModePerm)
	if err != nil {
		fmt.Println("Cannot Create Directory")
		return "Cannot create Client Directory", false
	}
	imagesDir := id + "/images"
	err = os.MkdirAll(imagesDir, os.ModePerm)
	if err != nil {
		fmt.Println("Cannot Create Directory")
		return "Cannot create Images Directory", false
	}
	filesDir := id + "/files"
	err = os.MkdirAll(filesDir, os.ModePerm)
	if err != nil {
		fmt.Println("Cannot Create Directory")
		return "Cannot create Files Directory", false
	}
	filename := imagesDir + "/logo.png"
	ok = copyFile("resources/logo.png", filename)
	if !ok {
		fmt.Println("Cannot copy image")
		return "Cannot copy Logo", false
	}
	imageAdder := getImageAdder(id)
	pdfAdder := getPDFAdder(id)
	tableAdder := getTableNumber()

	contentBefore, ok := getAllContentBeforeChapter1(id, document, subSystem, documentName)
	if !ok {
		return "Cannot make Main file", false
	}

	introContent, ok := makeIntroduction(id, documentName, imageAdder, pdfAdder, tableAdder)
	if !ok {
		return "Cannot create introduction file", false
	}

	checkoutContent, ok := makeCheckoutDetails(id, documentName, imageAdder, pdfAdder, tableAdder)
	if !ok {
		return "Cannot create Checkout Details page", false
	}
	testDetails, ok := makeTestDetails(id, documentName, imageAdder, pdfAdder, tableAdder)
	if !ok {
		return "Cannot create Test Details page", false
	}
	eidContent, ok := makeEID(id, documentName, imageAdder, pdfAdder, tableAdder)
	if !ok {
		return "Cannot create EID page", false
	}
	resultContent, ok := makeTestResults(id, documentName, imageAdder, pdfAdder, tableAdder)
	if !ok {
		return "Cannot create Test Results page", false
	}

	fullContent := ""
	fullContent = fullContent + contentBefore + "\n"
	fullContent = fullContent + introContent + "\n"
	fullContent = fullContent + checkoutContent + "\n"
	fullContent = fullContent + testDetails + "\n"
	fullContent = fullContent + "#set heading(numbering: none, supplement:none, outlined:false, bookmarked:false)\n= Annexure\n\n"
	fullContent = fullContent + "#show: appendix\n\n"
	fullContent = fullContent + eidContent + "\n"
	fullContent = fullContent + resultContent + "\n"

	typstFile := id + "/main.typ"
	err = os.WriteFile(typstFile, []byte(fullContent), 0666)
	if err != nil {
		return "Cannot write Typst file", false
	}

	return "", true
}

func Compile(id string) ([]byte, bool) {
	//	defer removeFolder(id)
	cmd := "typst"
	options := make([]string, 0)
	options = append(options, "compile")
	options = append(options, "main.typ")
	command := exec.Command(cmd, options...)
	command.Dir = "./" + id + "/"
	errMsg, err := command.CombinedOutput()
	if err != nil {
		// returning errMsg which is []byte as []byte from CombinedOutput
		return errMsg, false
	}

	file, err := os.ReadFile("./" + id + "/main.pdf")
	if err != nil {
		fmt.Println(err.Error())
		return make([]byte, 0), false
	}

	return file, true
}

func removeFolder(id string) {
	err := os.RemoveAll("./" + id)
	if err != nil {
		fmt.Println(err.Error())
	}
}

func GetSignaturePage(id string, documentName string) (string, bool) {
	var document = database.DocumentDetails{}
	var subSystem = database.SubsystemDetails{}
	var ok bool
	var errMsg string
	errMsg, document, ok = database.GetDocumentDetails(documentName)
	if !ok {
		fmt.Println(errMsg)
		return "Document doesn't exist", false
	}
	errMsg, subSystem, ok = database.GetSubsystemDetails(documentName)
	if !ok {
		fmt.Println(errMsg)
		return "Document doesn't exist", false
	}
	err := os.MkdirAll(id, os.ModePerm)
	if err != nil {
		fmt.Println("Cannot Create Directory")
		return "Cannot create Client Directory", false
	}
	imagesDir := id + "/images"
	err = os.MkdirAll(imagesDir, os.ModePerm)
	if err != nil {
		fmt.Println("Cannot Create Directory")
		return "Cannot create Images Directory", false
	}
	filesDir := id + "/files"
	err = os.MkdirAll(filesDir, os.ModePerm)
	if err != nil {
		fmt.Println("Cannot Create Directory")
		return "Cannot create Files Directory", false
	}
	filename := imagesDir + "/logo.png"
	ok = copyFile("resources/logo.png", filename)
	if !ok {
		fmt.Println("Cannot copy image")
		return "Cannot copy Logo", false
	}

	sign, ok := getSignaturePage(id, document, subSystem)
	if !ok {
		return "Cannot make Main file", false
	}

	fullContent := ""
	fullContent = fullContent + sign + "\n"

	typstFile := id + "/main.typ"
	err = os.WriteFile(typstFile, []byte(fullContent), 0666)
	if err != nil {
		return "Cannot write Typst file", false
	}

	return "", true
}
