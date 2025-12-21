package typst

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"unicode"

	"github.com/thedatashed/xlsxreader"
)

func copyFile(source string, dest string) bool {
	data, err := os.ReadFile(source)
	if err != nil {
		fmt.Println(err.Error())
		return false
	}
	err = os.WriteFile(dest, data, os.ModePerm)
	if err != nil {
		fmt.Println(err.Error())
		return false
	}
	return true
}

func getImageAdder(id string) func(string) (string, bool) {
	dest := id + "/images/"
	count := 0
	var imageAdder = func(source string) (string, bool) {
		name := "images" + strconv.Itoa(count) + ".png"
		filename := dest + name
		count = count + 1
		data, err := base64.StdEncoding.DecodeString(source)
		if err != nil {
			fmt.Println(err.Error())
			return "", false
		}
		err = os.WriteFile(filename, data, os.ModePerm)
		if err != nil {
			fmt.Println(err.Error())
			return "", false
		}
		return name, true
	}
	return imageAdder
}

func addImageContent(imageName string, caption string, landscape bool) string {
	content := ""
	if landscape {
		content = "#page(flipped: true)[\n"
	}
	content = content + "#figure(image(\"images/"
	content = content + imageName + "\"),caption:\""
	content = content + caption + "\")\n"
	if landscape {
		content = content + "]\n\n"
	}
	return content
}

func addText(text string) string {
	text = strings.ReplaceAll(text, "\n", "\n\n")
	content := "#cmarker.render(\"\n"
	content = content + text + "\n"
	content = content + "\")\n"
	content = content + "\n\n"
	return content
}

func getTableNumber() func() int {
	var tableNo = 0
	var table = func() int {
		tableNo = tableNo + 1
		return tableNo
	}
	return table
}

func addTable(table string, caption string, landscape bool, tableNo int) string {
	lines := strings.Split(table, "\n")
	colNames := strings.Split(lines[0], ",")
	header := "table.header(repeat: true,)"
	colSpec := "columns: (50pt,"
	header = header + "[*Sl. No*]"
	for _, col := range colNames {
		header = header + "[*" + col + "*]"
		colSpec = colSpec + "auto,"
	}
	header = header + ",\n"
	colSpec = colSpec + "),\n"

	csvString := ""
	lineNo := 1
	for i := 1; i < len(lines); i++ {
		if strings.EqualFold(strings.TrimSpace(lines[i]), "") {
			continue
		}
		lineAfterSerialNo := strconv.Itoa(lineNo) + "," + lines[i] + "\n"
		csvString = csvString + lineAfterSerialNo
		lineNo = lineNo + 1
	}

	var tableName = "table" + strconv.Itoa(tableNo)

	content := ""
	if landscape {
		content = "#page(flipped: true)[\n"
	}
	content = content + "#let " + tableName + " = csv.decode(\""
	content = content + csvString + "\")\n"
	content = content + "#show figure: set block(breakable: true)\n"
	content = content + "#figure(table(\n"
	content = content + colSpec
	content = content + header
	content = content + ".." + tableName + ".flatten(),\n"
	content = content + "),\n"
	content = content + "caption: \"" + caption + "\",\n"
	content = content + ")\n"
	if landscape {
		content = content + "]\n"
	}
	return content
}

func getPDFAdder(id string) func(string) (int, bool) {
	dest := id + "/files/"
	count := 0
	var pdfAdder = func(source string) (int, bool) {
		name := "file" + strconv.Itoa(count) + ".pdf"
		filename := dest + name
		fileID := count
		count = count + 1
		data, err := base64.StdEncoding.DecodeString(source)
		if err != nil {
			fmt.Println(err.Error())
			return fileID, false
		}
		fd, err := os.Create(filename)
		if err != nil {
			fmt.Println(err.Error())
			return count, false
		}
		n, err := fd.Write(data)
		fmt.Println("No of Bytes written ", n)
		if err != nil {
			fmt.Println(err.Error())
			return count, false
		}
		err = fd.Sync()
		if err != nil {
			fmt.Println(err.Error())
			return count, false
		}
		fd.Close()

		cwd, _ := os.Getwd()
		dir := "/" + id + "/files/"
		dir = cwd + dir

		outputFileName := "file" + strconv.Itoa(fileID) + "-%03d.svg"
		inputFileName := "file" + strconv.Itoa(fileID) + ".pdf"

		cmd := "convert"
		options := make([]string, 0)
		options = append(options, dir)
		options = append(options, outputFileName)
		options = append(options, inputFileName)
		command := exec.Command(cmd, options...)
		command.Dir, _ = os.Getwd()
		errMsg, err := command.CombinedOutput()
		if err != nil {
			fmt.Println(errMsg)
			return fileID, false
		}

		return fileID, true
	}
	return pdfAdder
}

func addPDFContent(id string, fileNum int, landscape bool) string {
	content := ""
	if landscape {
		content = "#page(flipped: true)["
	}
	dir := "./" + id + "/files/"
	for i := 1; i < 300; i++ {
		fileformat := "file" + strconv.Itoa(fileNum) + "-%0.3d.svg"

		fileName := fmt.Sprintf(fileformat, i)
		_, err := os.Stat(dir + fileName)
		if err == nil {
			content = content + "\n#image(\"files/" + fileName + "\", width: 90%, height:90%, fit:\"stretch\")\n"
		} else {
			fmt.Println("File", fileNum, "Page", i)
			break
		}
	}

	if landscape {
		content = content + "]\n\n"
	}
	return content
}

func addCodeContent(fileName string, data string) string {
	var newArray = make([]rune, 0)
	runeArray := []rune(data)
	for _, val := range runeArray {
		if val < unicode.MaxASCII {
			newArray = append(newArray, val)
		}
	}
	var sanitised = string(newArray)
	content := ""
	content = content + "#pagebreak()\n"
	content = content + "=== " + fileName + "\n\n"
	content = content + "```\n"
	content = content + sanitised
	content = content + "```\n"
	return content
}

func addImage(source string, filename string) bool {
	data, err := base64.StdEncoding.DecodeString(source)
	if err != nil {
		fmt.Println(err.Error())
		return false
	}
	err = os.WriteFile(filename, data, os.ModePerm)
	if err != nil {
		fmt.Println(err.Error())
		return false
	}
	return true
}

func addExcelContent(source string, caption string, landscape bool) string {
	data, err := base64.StdEncoding.DecodeString(source)
	if err != nil {
		fmt.Println(err.Error())
		return "Excel file cannot be decoded"
	}
	xl, _ := xlsxreader.NewReader(data)
	header := "table.header(repeat: true,)"
	first := true
	rowData := ""
	colSpec := "columns: ("
	for row := range xl.ReadRows(xl.Sheets[0]) {
		for _, cell := range row.Cells {
			if first {
				header = header + "[*" + cell.Value + "*]"
				colSpec = colSpec + "auto,"
			} else {
				rowData = rowData + "[`" + cell.Value + "`],\n"
			}

		}
		if first {
			header = header + ",\n"
			colSpec = colSpec + "),\n"
			first = false
		}

	}
	rowData = rowData + "\n"

	content := ""
	if landscape {
		content = "#page(flipped: true)[\n"
	}
	content = content + "#show figure: set block(breakable: true)\n"
	content = content + "#figure(table(\n"
	content = content + colSpec
	content = content + header
	content = content + rowData
	content = content + "),\n"
	content = content + "caption: \"" + caption + "\",\n"
	content = content + ")\n"
	if landscape {
		content = content + "]\n"
	}
	return content
}

func addRichText(text string) string {
	data, err := base64.StdEncoding.DecodeString(text)
	if err != nil {
		fmt.Println(err.Error())
		return "Content Cannot be added"
	}
	var deltas []Delta
	json.Unmarshal(data, &deltas)
	content := getTypstString(deltas)
	return content
}

func getTypstString(deltas []Delta) string {
	var tbr = ""
	var prevLine = ""
	for i := 0; i < len(deltas); i++ {
		delta := deltas[i]
		delta.Insert = strings.ReplaceAll(delta.Insert, "*", "\\*")
		delta.Insert = strings.ReplaceAll(delta.Insert, "-", "\\-")
		delta.Insert = strings.ReplaceAll(delta.Insert, "_", "\\_")
		delta.Insert = strings.ReplaceAll(delta.Insert, "=", "\\=")
		delta.Insert = strings.ReplaceAll(delta.Insert, "`", "\\`")
		if !delta.getIfDeltaIsBlock() {
			lines := strings.Split(delta.Insert, "\n")
			for i := 0; i < len(lines)-1; i++ {
				var newDelta Delta
				newDelta.Insert = prevLine + lines[i]
				prevLine = ""
				newDelta.Attributes = delta.Attributes
				tbr = tbr + getTypstStringForDelta(newDelta) + "\n\n"
			}
			var newDelta Delta
			newDelta.Insert = lines[len(lines)-1]
			newDelta.Attributes = delta.Attributes
			prevLine = prevLine + getTypstStringForDelta(newDelta)

		} else {
			var newDelta Delta
			newDelta.Insert = prevLine
			newDelta.Attributes = delta.Attributes
			tbr = tbr + getTypstStringForDelta(newDelta) + "\n"
			prevLine = ""
		}
	}
	return tbr
}

func getTypstStringForDelta(delta Delta) string {
	var tbr string
	tbr = delta.Insert
	if delta.Attributes == nil {
		return tbr
	}
	if delta.Attributes.Bold {
		tbr = "* " + tbr + " *"
	}
	if delta.Attributes.Italic {
		tbr = "_ " + tbr + " _"
	}
	if delta.Attributes.Underline {
		tbr = "#underline[" + tbr + "]"
	}
	if delta.Attributes.InlineCode {
		tbr = "` " + tbr + " `"
	}
	if !strings.EqualFold(delta.Attributes.Color, "") {
		var color = string(delta.Attributes.Color[0])
		color = color + delta.Attributes.Color[3:]
		tbr = "#text(fill:rgb(\"" + color + "\"))[" + tbr + "]"
	}
	if !strings.EqualFold(delta.Attributes.Background, "") {
		var color = string(delta.Attributes.Background[0])
		color = color + delta.Attributes.Background[3:]
		tbr = "#highlight(fill:rgb(\"" + color + "\"))[" + tbr + "]"
	}
	if delta.Attributes.Strikethrough {
		tbr = "#strike[" + tbr + "]"
	}
	if strings.EqualFold(delta.Attributes.Script, "sub") {
		tbr = "#sub[" + tbr + "]"
	}
	if strings.EqualFold(delta.Attributes.Script, "super") {
		tbr = "#super[" + tbr + "]"
	}
	if strings.EqualFold(delta.Attributes.List, "bullet") {
		var spaces = ""
		for i := 0; i < delta.Attributes.Indent; i++ {
			spaces = spaces + "   "
		}
		tbr = spaces + "- " + tbr
	}
	if strings.EqualFold(delta.Attributes.List, "ordered") {
		var spaces = ""
		for i := 0; i < delta.Attributes.Indent; i++ {
			spaces = spaces + "   "
		}
		tbr = spaces + "+ " + tbr
	}
	if delta.Attributes.Header != 0 {
		var header = ""
		for i := 0; i < delta.Attributes.Header; i++ {
			header = header + "="
		}
		tbr = header + " " + tbr
	}
	return tbr
}
