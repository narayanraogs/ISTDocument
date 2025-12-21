package typst

import "strings"

type Delta struct {
	Insert     string     `json:"insert"`
	Retain     string     `json:"retain"`
	Delete     string     `json:"delete"`
	Attributes *Attribute `json:"attributes"`
}

type Attribute struct {
	//For Specific Items
	Underline     bool   `json:"underline"`
	Bold          bool   `json:"bold"`
	InlineCode    bool   `json:"code"`
	Italic        bool   `json:"italic"`
	Color         string `json:"color"`
	Background    string `json:"background"`
	Font          string `json:"font"` // To be ignored
	Link          string `json:"link"` // To be ignored
	Size          int    `json:"size"` // To be ignored
	Strikethrough bool   `json:"strike"`
	Script        string `json:"script"`
	//For Block
	List       string `json:"list"`
	Indent     int    `json:"indent"`
	Align      string `json:"align"`     //To be Ignored?
	Direction  string `json:"direction"` //To be Ignored
	Header     int    `json:"header"`
	CodeBlock  bool   `json:"code-block"`
	Blockquote bool   `json:"blockquote"`
	//3 Embeds are there - Not supported as of now
	//Image
	//Video
	//Formula
}

func (delta *Delta) getIfDeltaIsBlock() bool {
	if strings.EqualFold(delta.Insert, "\n") && delta.Attributes != nil {
		return true
	} else {
		return false
	}
}
