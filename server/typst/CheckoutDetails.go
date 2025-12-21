package typst

import (
	"intDocument/server/database"
)

func makeCheckoutDetails(id string, documentName string, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) (string, bool) {
	content := `
	
	= Checkout Details
	`

	errMsg, inter, ok := database.GetContent(documentName, "Checkout-Interface")
	if !ok {
		content = content + "Error in Cehckout Interface: " + errMsg
		return content, false
	}
	interfaceContent := makeInterface(id, inter, imageAdder, pdfAdder, tableAdder)
	content = content + interfaceContent

	errMsg, spec, ok := database.GetContent(documentName, "Checkout-SpecificRequirements")
	if !ok {
		content = content + "Error in Specific Requirements: " + errMsg
		return content, false
	}
	specReq := makeSpecificRequirements(id, spec, imageAdder, pdfAdder, tableAdder)
	content = content + specReq

	errMsg, safety, ok := database.GetContent(documentName, "Checkout-SafetyRequirements")
	if !ok {
		content = content + "Error in Safety Requirements: " + errMsg
		return content, false
	}
	safetyReq := makeSafetyRequirements(id, safety, imageAdder, pdfAdder, tableAdder)
	content = content + safetyReq

	errMsg, tp, ok := database.GetContent(documentName, "Checkout-TestPhilosophy")
	if !ok {
		content = content + "Error in Test Philosophy: " + errMsg
		return content, false
	}
	telecommand := makeTestPhilosophy(id, tp, imageAdder, pdfAdder, tableAdder)
	content = content + telecommand

	errMsg, ssClar, ok := database.GetContent(documentName, "Checkout-SubsystemClarifications")
	if !ok {
		content = content + "Error in Subsystem Clarification: " + errMsg
		return content, false
	}
	ssCalrification := makeSubsystemClarification(id, ssClar, imageAdder, pdfAdder, tableAdder)
	content = content + ssCalrification

	content = content + "#pagebreak()"
	return content, true
}

func makeInterface(id string, inter database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := `
	== Checkout Interface
	`
	interContent := addContent(id, inter, imageAdder, pdfAdder, tableAdder)
	content = content + interContent
	return content
}

func makeSpecificRequirements(id string, specReq database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := "#pagebreak()" + "\n"
	content = content + `== Specific Requirements
	`
	spec := addContent(id, specReq, imageAdder, pdfAdder, tableAdder)
	content = content + spec
	return content
}

func makeSafetyRequirements(id string, safetyReq database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := `== Safety Requirements
	`
	safety := addContent(id, safetyReq, imageAdder, pdfAdder, tableAdder)
	content = content + safety
	return content
}

func makeTestPhilosophy(id string, tp database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := `== Test Philosophy
	`
	testPhilosophy := addContent(id, tp, imageAdder, pdfAdder, tableAdder)
	content = content + testPhilosophy
	return content
}

func makeSubsystemClarification(id string, ssClarifcation database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := `== Subsystem Clarification
	`
	ssClar := addContent(id, ssClarifcation, imageAdder, pdfAdder, tableAdder)
	content = content + ssClar
	return content
}
