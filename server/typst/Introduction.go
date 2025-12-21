package typst

import (
	"fmt"
	"intDocument/server/database"
)

func makeIntroduction(id string, documentName string, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) (string, bool) {
	errMsg, subSystem, ok := database.GetSubsystemDetails(documentName)
	if !ok {
		fmt.Println(errMsg)
		return "", false
	}
	content := `
	= Introduction
	`
	abstract := makeAbstract(subSystem)
	content = content + abstract + "\n"

	errMsg, acronyms, ok := database.GetContent(documentName, "Introduction-Acronyms")
	if !ok {
		content = content + "Error in Subsystem Introduction: " + errMsg
	}
	acro := makeAcronyms(id, acronyms, imageAdder, pdfAdder, tableAdder)
	content = content + acro

	errMsg, introContent, ok := database.GetContent(documentName, "Introduction-SSIntroduction")
	if !ok {
		content = content + "Error in Subsystem Introduction: " + errMsg
	}
	ssIntro := makeSSIntroduction(id, introContent, imageAdder, pdfAdder, tableAdder)
	content = content + ssIntro

	errMsg, specContent, ok := database.GetContent(documentName, "Introduction-SSSpecification")
	if !ok {
		content = content + "Error in Subsystem Specification: " + errMsg
	}
	ssSpec := makeSSSpecification(id, specContent, imageAdder, pdfAdder, tableAdder)
	content = content + ssSpec

	errMsg, tc, ok := database.GetContent(documentName, "Introduction-Telecommand")
	if !ok {
		content = content + "Error in Telecommand: " + errMsg
	}
	telecommand := makeTelecommand(id, tc, imageAdder, pdfAdder, tableAdder)
	content = content + telecommand

	errMsg, tm, ok := database.GetContent(documentName, "Introduction-Telemetry")
	if !ok {
		content = content + "Error in Telemetry: " + errMsg
	}
	telemetry := makeTelemetry(id, tm, imageAdder, pdfAdder, tableAdder)
	content = content + telemetry

	errMsg, pages, ok := database.GetContent(documentName, "Introduction-Pages")
	if !ok {
		content = content + "Error in Pages: " + errMsg
	}
	page := makePages(id, pages, imageAdder, pdfAdder, tableAdder)
	content = content + page

	content = content + "#pagebreak()"

	return content, true
}

func makeAbstract(subSystem database.SubsystemDetails) string {
	content := `
	== Abstract
	This document briefly describes the #ssName of #satName an `
	content = content + subSystem.SatelliteClass
	content = content + " class of Satellite, and gives all aspects related to Integrated satellite test(IST), namely\n"
	content = content + `	
		- Mnemonics for TM and TC
		- TM Pages
		- Possible status displays for TM parameters
		- IST test matrix
		- IST plans
		- IST Procedures
		- IST Test Report Formats
		- Any Specific Requirements


	Above aspects are covered in various chapters as given in the contents.
	`
	return content
}

func makeAcronyms(id string, acro database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := `
	== Acronyms
	`
	introduction := addContent(id, acro, imageAdder, pdfAdder, tableAdder)
	content = content + introduction
	return content
}

func makeSSIntroduction(id string, intro database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := `
	== Introduction to Subsystem
	`
	introduction := addContent(id, intro, imageAdder, pdfAdder, tableAdder)
	content = content + introduction
	return content
}

func makeSSSpecification(id string, spec database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := `
	== Specification of Subsystem
	`
	introduction := addContent(id, spec, imageAdder, pdfAdder, tableAdder)
	content = content + introduction
	return content
}

func makeTelecommand(id string, tc database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := "#pagebreak()" + "\n"
	content = content + `
	== Telecommand Details
	`
	introduction := addContent(id, tc, imageAdder, pdfAdder, tableAdder)
	content = content + introduction
	return content
}

func makeTelemetry(id string, tm database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := "#pagebreak()" + "\n"
	content = content + `
	== Telemetry Details
	`
	introduction := addContent(id, tm, imageAdder, pdfAdder, tableAdder)
	content = content + introduction
	return content
}

func makePages(id string, page database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := "#pagebreak()" + "\n"
	content = content + `
	== Pages
	`
	introduction := addContent(id, page, imageAdder, pdfAdder, tableAdder)
	content = content + introduction
	return content
}
