package database

import (
	"fmt"
	"strings"

	"go.mills.io/bitcask/v2"
)

func AddDocument(documentName string) (string, bool) {
	c := db.Collection(documentName)
	if c.Exists() {
		return "Duplicate Document Name", false
	}
	var documentDetails DocumentDetails
	var subsystemDetails SubsystemDetails

	err := c.Add("DocumentDetails", documentDetails)
	if err != nil {
		return err.Error(), false
	}
	err = c.Add("SubsystemDetails", subsystemDetails)
	if err != nil {
		return err.Error(), false
	}
	var subsectionNames = make([]string, 0)
	subsectionNames = append(subsectionNames, "Introduction-Acronyms")
	subsectionNames = append(subsectionNames, "Introduction-SSIntroduction")
	subsectionNames = append(subsectionNames, "Introduction-SSSpecification")
	subsectionNames = append(subsectionNames, "Introduction-Telecommand")
	subsectionNames = append(subsectionNames, "Introduction-Telemetry")
	subsectionNames = append(subsectionNames, "Introduction-Pages")
	subsectionNames = append(subsectionNames, "Checkout-Interface")
	subsectionNames = append(subsectionNames, "Checkout-SpecificRequirements")
	subsectionNames = append(subsectionNames, "Checkout-SafetyRequirements")
	subsectionNames = append(subsectionNames, "Checkout-TestPhilosophy")
	subsectionNames = append(subsectionNames, "Checkout-SubsystemClarifications")
	subsectionNames = append(subsectionNames, "TestMatrix")
	subsectionNames = append(subsectionNames, "TestPlans")
	subsectionNames = append(subsectionNames, "TestProcedures")
	subsectionNames = append(subsectionNames, "Annexure-EID")
	subsectionNames = append(subsectionNames, "Annexure-TestResultsFormat")

	errMsg, ok := addEmptyContent(subsectionNames, c)
	if !ok {
		return errMsg, false
	}

	l := db.List(bitcask.Key("documentNames"))
	err = l.Append(bitcask.Value(documentName))
	if err != nil {
		return err.Error(), false
	}
	return "", true
}

func addEmptyContent(sectionNames []string, c *bitcask.Collection) (string, bool) {
	var content Content
	content.NoOfItems = 0
	content.ContentType = make([]string, 0)
	content.FileName = make([]string, 0)
	content.Value = make([]string, 0)
	content.Captions = make([]string, 0)
	content.Landscape = make([]bool, 0)

	for i := 0; i < len(sectionNames); i++ {
		err := c.Add(sectionNames[i], content)
		if err != nil {
			return err.Error(), false
		}
	}
	return "", true

}

func AddDocumentDetails(documentName string, documentDetails DocumentDetails) (string, bool) {
	c := db.Collection(documentName)
	if !c.Exists() {
		return "Document Doesn't Exist", false
	}
	err := c.Add("DocumentDetails", documentDetails)
	if err != nil {
		return err.Error(), false
	}
	return "", true
}

func AddSubsystemDetails(documentName string, subsystemDetails SubsystemDetails) (string, bool) {
	c := db.Collection(documentName)
	if !c.Exists() {
		return "Document Doesn't Exist", false
	}
	err := c.Add("SubsystemDetails", subsystemDetails)
	if err != nil {
		fmt.Println(err.Error())
		return err.Error(), false
	}
	return "", true
}

func AddContent(documentName string, subsection string, content Content) (string, bool) {
	c := db.Collection(documentName)
	if !c.Exists() {
		return "Document Doesn't Exist", false
	}
	err := c.Add(subsection, content)
	if err != nil {
		fmt.Println(err.Error())
		return err.Error(), false
	}
	return "", true
}

func CopyDocument(documentName string, newDocumentName string) (string, bool) {
	c := db.Collection(newDocumentName)
	if c.Exists() {
		return "Duplicate Document Name", false
	}
	cOld := db.Collection(documentName)
	if !cOld.Exists() {
		return "Duplicate Doesn't Exist", false
	}

	_, documentDetails, ok := GetDocumentDetails(documentName)
	if !ok {
		return "Problem with old Document", false
	}
	err := c.Add("DocumentDetails", documentDetails)
	if err != nil {
		return err.Error(), false
	}

	_, subsystemDetails, ok := GetSubsystemDetails(documentName)
	if !ok {
		return "Problem with old Document", false
	}
	err = c.Add("SubsystemDetails", subsystemDetails)
	if err != nil {
		return err.Error(), false
	}
	var subsectionNames = make([]string, 0)
	subsectionNames = append(subsectionNames, "Introduction-Acronyms")
	subsectionNames = append(subsectionNames, "Introduction-SSIntroduction")
	subsectionNames = append(subsectionNames, "Introduction-SSSpecification")
	subsectionNames = append(subsectionNames, "Introduction-Telecommand")
	subsectionNames = append(subsectionNames, "Introduction-Telemetry")
	subsectionNames = append(subsectionNames, "Introduction-Pages")
	subsectionNames = append(subsectionNames, "Checkout-Interface")
	subsectionNames = append(subsectionNames, "Checkout-SpecificRequirements")
	subsectionNames = append(subsectionNames, "Checkout-SafetyRequirements")
	subsectionNames = append(subsectionNames, "Checkout-TestPhilosophy")
	subsectionNames = append(subsectionNames, "Checkout-SubsystemClarifications")
	subsectionNames = append(subsectionNames, "TestMatrix")
	subsectionNames = append(subsectionNames, "TestPlans")
	subsectionNames = append(subsectionNames, "TestProcedures")
	subsectionNames = append(subsectionNames, "Annexure-EID")
	subsectionNames = append(subsectionNames, "Annexure-TestResultsFormat")

	copyContent(documentName, subsectionNames, c)
	l := db.List(bitcask.Key("documentNames"))
	err = l.Append(bitcask.Value(newDocumentName))
	if err != nil {
		return err.Error(), false
	}
	return "", true
}

func copyContent(documentName string, sectionNames []string, c *bitcask.Collection) (string, bool) {
	for i := 0; i < len(sectionNames); i++ {
		_, content, ok := GetContent(documentName, sectionNames[i])
		if !ok {
			return "Problem with old Document", false
		}
		err := c.Add(sectionNames[i], content)
		if err != nil {
			return err.Error(), false
		}
	}
	return "", true
}

func DeleteDocument(documentName string) (string, bool) {
	c := db.Collection(documentName)
	if !c.Exists() {
		return "Document Doesn't Exist", false
	}
	err := c.Drop()
	if err != nil {
		return "Document Can't be deleted", false
	}
	db.Sync()
	l := db.List(bitcask.Key("documentNames"))
	length, err := l.Len()
	if err != nil {
		fmt.Println("Error when reading Document Names", err.Error())
		return "Error When reading Document Names", false
	}
	var newNames = make([]string, 0)
	for i := 0; i < int(length); i++ {
		data, err := l.Index(int64(i))
		if err != nil {
			return "Cannot read Document Names", false
		}
		name := string(data)
		if len(strings.TrimSpace(name)) > 0 && name != documentName {
			newNames = append(newNames, name)
		}
	}
	for i := 0; i < int(length); i++ {
		l.Pop()
	}
	db.Sync()
	for i := 0; i < len(newNames); i++ {
		l.Append(bitcask.Value(newNames[i]))
	}
	db.Sync()
	return "", true
}
