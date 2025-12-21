package client

type ClientID struct {
	ID string
}

type DocumentNamesResponse struct {
	OK            bool
	Message       string
	DocumentNames []string
}

type AddDocument struct {
	ID   string
	Name string
}

type Ack struct {
	OK      bool
	Message string
}

type DocumentDetails struct {
	DocumentNumber      string
	PreparedBy          string
	ReviewedByName      string
	ReviewedByTitle     string
	FirstApproverName   string
	FirstApproverTitle  string
	SecondApproverName  string
	SecondApproverTitle string
	EID                 bool
	ResultFormat        bool
	OK                  bool
	Message             string
}

type DocumentDetailsRequest struct {
	ID                  string
	DocumentName        string
	DocumentNumber      string
	PreparedBy          string
	ReviewedByName      string
	ReviewedByTitle     string
	FirstApproverName   string
	FirstApproverTitle  string
	SecondApproverName  string
	SecondApproverTitle string
	EID                 bool
	ResultFormat        bool
}

type SubsystemDetails struct {
	SatelliteClass string
	SatelliteName  string
	SubsystemName  string
	SatelliteImage string
	OK             bool
	Message        string
}

type SubsystemDetailsRequest struct {
	ID             string
	DocumentName   string
	SatelliteClass string
	SatelliteName  string
	SubsystemName  string
	SatelliteImage string
}

type ContentRequest struct {
	ID           string
	DocumentName string
	Subsection   string
}

type ContentResponse struct {
	NoOfItems   int
	ContentType []string
	FileName    []string
	Value       []string
	Captions    []string
	Landscape   []bool
	OK          bool
	Message     string
}

type AddContentRequest struct {
	ID           string
	DocumentName string
	Subsection   string
	NoOfItems    int
	ContentType  []string
	FileName     []string
	Value        []string
	Captions     []string
	Landscape    []bool
}

type CopyDocument struct {
	ID      string
	OldName string
	NewName string
}

type PDFResponse struct {
	Content string
	OK      bool
	Message string
}
