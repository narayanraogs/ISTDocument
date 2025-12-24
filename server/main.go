package main

import (
	"embed"
	"flag"
	"fmt"
	"intDocument/server/client"
	"intDocument/server/config"
	"intDocument/server/database"
	"io/fs"
	"log"
)

var Version string

//go:embed all:web
var embeddedFiles embed.FS
var cfgPath = flag.String("cfg", "/home/csrspdev/development/istdocument/config/config.json", "Config File Path")

func init() {
	flag.Parse()
}

func main() {
	fmt.Printf("Starting IST Document Generator server, Version: %s\n", Version)
	fmt.Println("Config Path: ", *cfgPath)
	err := config.ReadConfiguration(*cfgPath)
	if err != nil {
		log.Fatalf("Failed to read configuration: %v", err)
	}
	_, ok := database.Connect()
	if !ok {
		log.Fatal("Cannot connect to Database")
	}

	// Get the subtree of the embedded files, so we can serve it from the root.
	webFS, err := fs.Sub(embeddedFiles, "web")
	if err != nil {
		log.Fatalf("Error getting embedded web files: %v", err)
	}
	client.Listen(webFS, config.Config.PortNo)
}
