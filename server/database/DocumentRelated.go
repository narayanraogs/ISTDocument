package database

import (
	"fmt"

	"go.mills.io/bitcask/v2"
)

func GetAllDocumentNames() ([]string, bool) {
	var documentNames = make([]string, 0)
	l := db.List(bitcask.Key("documentNames"))
	length, err := l.Len()
	if err != nil {
		fmt.Println("Error when reading Document Names", err.Error())
		return documentNames, false
	}
	var i int64
	for i = 0; i < length; i++ {
		value, err := l.Index(i)
		if err != nil {
			fmt.Println("Error when reading Document Name", err.Error())
			return documentNames, false
		}
		documentNames = append(documentNames, string(value))
	}
	return documentNames, true
}

func GetDocumentDetails(documentName string) (string, DocumentDetails, bool) {
	details := DocumentDetails{}
	c := db.Collection(documentName)
	if !c.Exists() {
		return "Document Doesn't Exist", details, false
	}
	err := c.Get("DocumentDetails", &details)

	if err != nil {
		return err.Error(), details, false
	}
	return "", details, true
}

func GetSubsystemDetails(documentName string) (string, SubsystemDetails, bool) {
	details := SubsystemDetails{}
	c := db.Collection(documentName)
	if !c.Exists() {
		return "Document Doesn't Exist", details, false
	}
	err := c.Get("SubsystemDetails", &details)

	if err != nil {
		return err.Error(), details, false
	}
	return "", details, true
}

func GetContent(documentName string, subsection string) (string, Content, bool) {
	details := Content{}
	c := db.Collection(documentName)
	if !c.Exists() {
		return "Document Doesn't Exist", details, false
	}
	err := c.Get(subsection, &details)

	if err != nil {
		return err.Error(), details, false
	}
	return "", details, true
}
