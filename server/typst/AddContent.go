package typst

import (
	"fmt"
	"intDocument/server/database"
	"strings"
)

func addContent(id string, cnt database.Content, imageAdder func(string) (string, bool), pdfAdder func(string) (int, bool), tableAdder func() int) string {
	content := "\n"
	if cnt.NoOfItems == 0 {
		content = content + "Not Applicable\n"
		return content
	}

	for i := 0; i < cnt.NoOfItems; i++ {
		contentType := strings.ToLower(cnt.ContentType[i])
		switch contentType {
		case "text":
			text := addText(cnt.Value[i])
			content = content + text + "\n"
		case "image":
			imageName, ok := imageAdder(cnt.Value[i])
			if !ok {
				fmt.Println("Cannot add Image")
				continue
			}
			img := addImageContent(imageName, cnt.Captions[i], cnt.Landscape[i])
			content = content + img + "\n"

		case "table":
			tableNo := tableAdder()
			tbl := addTable(cnt.Value[i], cnt.Captions[i], cnt.Landscape[i], tableNo)
			content = content + tbl + "\n\n"
		case "file":
			filename, ok := pdfAdder(cnt.Value[i])
			if !ok {
				fmt.Println("Cannot add File")
				continue
			}
			file := addPDFContent(id, filename, cnt.Landscape[i])
			content = content + file + "\n"
		case "code":
			code := addCodeContent(cnt.FileName[i], cnt.Value[i])
			content = content + code + "\n"
		case "excel":
			excel := addExcelContent(cnt.Value[i], cnt.Captions[i], cnt.Landscape[i])
			content = content + excel + "\n"
		case "richtext":
			rich := addRichText(cnt.Value[i])
			content = content + rich + "\n"
		default:
			content = content + "unknown content type\n\n"
		}
	}
	return content
}
