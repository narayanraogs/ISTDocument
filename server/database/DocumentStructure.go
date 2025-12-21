package database

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
}

type SubsystemDetails struct {
	SatelliteClass string
	SatelliteName  string
	SubsystemName  string
	SatelliteImage string
}

type Content struct {
	NoOfItems   int
	ContentType []string
	FileName    []string
	Value       []string
	Captions    []string
	Landscape   []bool
}
