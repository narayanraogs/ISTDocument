package typst

import (
	"intDocument/server/database"
	"time"
)

func getAllContentBeforeChapter1(id string, document database.DocumentDetails, subsystem database.SubsystemDetails, documentName string) (string, bool) {
	var content string
	docNo := "#let docNum = \"" + document.DocumentNumber + "\"\n"
	docTitle := "#let docTitle = \"IST Document for " + subsystem.SubsystemName + " system of " + subsystem.SatelliteName + "\"\n"
	now := time.Now()
	today := now.Format("02-Jan-2006")
	date := "#let today = \"" + today + "\"\n"
	monthGo := now.Format("Jan 2006")
	month := "#let month = \"" + monthGo + "\"\n"
	ssName := "#let ssName = \"" + subsystem.SubsystemName + "\"\n"
	satName := "#let satName = \"" + subsystem.SatelliteName + "\"\n"
	preparedBy := "#let preparedBy = \"" + document.PreparedBy + "\"\n"
	reviewerName := "#let reviewerName = \"" + document.ReviewedByName + "\"\n"
	reviewerTitle := "#let reviewerTitle = \"" + document.ReviewedByTitle + "\"\n"
	app1Name := "#let app1Name = \"" + document.FirstApproverName + "\"\n"
	app1Title := "#let app1Title = \"" + document.FirstApproverTitle + "\"\n"
	app2Name := "#let app2Name = \"" + document.SecondApproverName + "\"\n"
	app2Title := "#let app2Title = \"" + document.SecondApproverTitle + "\"\n"
	addImage(subsystem.SatelliteImage, id+"/images/scImage.png")

	content = docNo
	content = content + docTitle + date + month + "\n"
	content = content + ssName + satName + "\n"
	content = content + preparedBy + reviewerName + reviewerTitle + "\n"
	content = content + app1Name + app1Title + app2Name + app2Title + "\n"

	content = content + `
	#import "@preview/cmarker:0.1.0"
	#set heading(numbering: "1.1", supplement:[Chapter])
	#set par(justify: true,leading:1.15em)
	#set block(spacing:1.5em)
	#set list(indent: 10pt)
	#set text(font: "Roboto")
	#set page(
  		margin: (
    		top: 4cm,
    		x: 1.5cm,
    		bottom:2cm
  		),
  		header:
		table(
  		columns: (10fr, 40fr, 20fr,30fr), 
  		rows: 3,
  		table.cell(rowspan: 3,image("images/logo.png")),
  		table.cell(rowspan: 2,align: center, [#docNum]),
  		[Issue: A],
  		[
    	Page
  		#context(counter(page).display(
    	"1 of 1",
    	both: true,
		))],
  	[Revision: 0],
  	[Issue Date: #today],
  	table.cell(colspan: 3, align: center, [#docTitle])  
	), 
	footer: context[
  	#h(1fr)
	#text(8pt)[URSC Quality Policy: Committed to total quality and Zero defect in Space Systems and Services through Continual Improvement]
  	#h(1fr)
	],)
	#let appendix(body) = {
		set heading(numbering: "A", supplement: [Appendix],outlined:true,bookmarked:true)
		counter(heading).update(0)
		body
	}

	`

	content = content + "#linebreak()"
	content = content + `
	#align(center)[
		#text(18pt)[
			#satName #linebreak()
			Integrated Spacecraft Test Document #linebreak()
			of #linebreak()
			#ssName #linebreak()
		]
	]
	#v(1fr)
	#align(center,image("images/scImage.png"))
	#v(1fr)
	#pagebreak()
	#linebreak()
	`

	page2, page2Image := getPage2Image(id, documentName)
	if !page2Image {
		page2 = getPage2Created()
	}

	content = content + page2

	content = content + `
	#pagebreak()
	#linebreak()
	#text(size:18pt)[*Change History*]
	#table(
		align:center,
		columns:(1fr, 2fr, 2fr, 2fr, 2fr),
		rows:10,
		[*Version No*], [*Date*], [*Affected Section, Figure, Table*], [*Nature of Change[A, M, D]\**],[*Description*],
		[1.0],[#month],[New],[New],[Initial Issue],
	)
	$*$ A - Addition, D - Deletion, M - Modification
	#pagebreak()
	#linebreak()
	#text(size:18pt)[*Document Distribution List*]
	#table(
		align:center,
		columns:(1fr, 2fr, 2fr),
		rows:10,
		[*Copy No*], [*Issued to*], [*Remarks*],
		[1],[ISO Record],[Softcopy],
		[2],[Master Copy Originator (Uncontrolled)],[Softcopy],
		[3],[Committee Members],[Softcopy],
	)
	#pagebreak()
	#outline(
		target:heading.where(supplement:[Chapter]),
		title: [Table of Contents],
		indent: auto,
		depth: 3,
	)
	#outline(
		target:heading.where(supplement:[Appendix]),
		title: [Annexure],
		indent: auto
	)
	#pagebreak()
	#outline(
		title: [List of Figures],
		target: figure.where(kind:image),
	)
	#outline(
		title: [List of Tables],
		target: figure.where(kind:table),
	)
	#pagebreak()
	`

	return content, true

}

func getSignaturePage(id string, document database.DocumentDetails, subsystem database.SubsystemDetails) (string, bool) {
	var content string
	docNo := "#let docNum = \"" + document.DocumentNumber + "\"\n"
	docTitle := "#let docTitle = \"IST Document for " + subsystem.SubsystemName + " system of " + subsystem.SatelliteName + "\"\n"
	now := time.Now()
	today := now.Format("02-Jan-2006")
	date := "#let today = \"" + today + "\"\n"
	monthGo := now.Format("Jan 2006")
	month := "#let month = \"" + monthGo + "\"\n"
	ssName := "#let ssName = \"" + subsystem.SubsystemName + "\"\n"
	satName := "#let satName = \"" + subsystem.SatelliteName + "\"\n"
	preparedBy := "#let preparedBy = \"" + document.PreparedBy + "\"\n"
	reviewerName := "#let reviewerName = \"" + document.ReviewedByName + "\"\n"
	reviewerTitle := "#let reviewerTitle = \"" + document.ReviewedByTitle + "\"\n"
	app1Name := "#let app1Name = \"" + document.FirstApproverName + "\"\n"
	app1Title := "#let app1Title = \"" + document.FirstApproverTitle + "\"\n"
	app2Name := "#let app2Name = \"" + document.SecondApproverName + "\"\n"
	app2Title := "#let app2Title = \"" + document.SecondApproverTitle + "\"\n"

	content = docNo
	content = content + docTitle + date + month + "\n"
	content = content + ssName + satName + "\n"
	content = content + preparedBy + reviewerName + reviewerTitle + "\n"
	content = content + app1Name + app1Title + app2Name + app2Title + "\n"

	content = content + `
	#import "@preview/cmarker:0.1.0"
	#set heading(numbering: "1.1", supplement:[Chapter])
	#set par(justify: true,leading:1.15em)
	#set block(spacing:1.5em)
	#set list(indent: 10pt)
	#set text(font: "Roboto")
	#set page(
  		margin: (
    		top: 4cm,
    		x: 1.5cm,
    		bottom:2cm
  		),
	)
	#linebreak()
	#align(center)[
		#text(18pt)[
			#satName #linebreak()
			Integrated Spacecraft Test Document #linebreak()
			of #linebreak()
			#ssName #linebreak()
		]
	]
	#v(1fr)
	#align(center)[
		Prepared By, #linebreak()
		#preparedBy
	]
	#v(1fr)
	#align(center)[
		Reviewed By, #linebreak()
		#linebreak()
		#linebreak()
		#reviewerName #linebreak()
		#reviewerTitle
	]
	#v(1fr)
	#align(center)[Approved By,]
	#linebreak()
	#linebreak()
	#grid(
		columns:(1fr,1fr),
		grid.cell(align:center)[
			#app1Name , #linebreak()
			#app1Title
		],
		grid.cell(align:center)[
			#app2Name , #linebreak()
			#app2Title
		],
	)
	#v(1fr)
	#align(center)[#month]
	#v(1fr)
	#align(center)[
		U R Rao Satellite Center #linebreak()
		Indian Space Research Organization #linebreak()
		Bangalore
	]
	`
	return content, true
}

func getPage2Created() string {
	content := `
	#align(center)[
		#text(18pt)[
			#satName #linebreak()
			Integrated Spacecraft Test Document #linebreak()
			of #linebreak()
			#ssName #linebreak()
		]
	]
	#v(1fr)
	#align(center)[
		Prepared By, #linebreak()
		#preparedBy
	]
	#v(1fr)
	#align(center)[
		Reviewed By, #linebreak()
		#linebreak()
		#linebreak()
		#reviewerName #linebreak()
		#reviewerTitle
	]
	#v(1fr)
	#align(center)[Approved By,]
	#linebreak()
	#linebreak()
	#grid(
		columns:(1fr,1fr),
		grid.cell(align:center)[
			#app1Name , #linebreak()
			#app1Title
		],
		grid.cell(align:center)[
			#app2Name , #linebreak()
			#app2Title
		],
	)
	#v(1fr)
	#align(center)[#month]
	#v(1fr)
	#align(center)[
		U R Rao Satellite Center #linebreak()
		Indian Space Research Organization #linebreak()
		Bangalore
	]
	`
	return content
}

func getPage2Image(id string, documentName string) (string, bool) {
	content := ""
	errMsg, page2, ok := database.GetContent(documentName, "Information-SignedPage")
	if !ok {
		content = content + "Error in Cehckout Interface: " + errMsg
		return content, false
	}
	if page2.NoOfItems == 0 {
		return content, false
	}
	ok = addImage(page2.Value[0], id+"/images/signImage.png")
	if !ok {
		return content, false
	}
	content = `
	#v(1fr)
	#align(center,image("images/signImage.png"))
	#v(1fr)
	`
	return content, true
}
