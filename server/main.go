package main

import (
	"embed"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"path/filepath"
)

var Version string

//go:embed all:web
var embeddedFiles embed.FS
var cfgPath = flag.String("cfg", "/home/csrspdev/Development/tmCompare/config/config.json", "Config File Path")

func init() {
	flag.Parse()
}

func main() {
	fmt.Printf("Starting tmCompare server, Version: %s\n", Version)
	generic.ReadConfiguration(*cfgPath)
	logPath := filepath.Join(generic.Config.BasePath, generic.Config.LogPath)
	logger.InitializeLog(logPath)
	connectDatabase()

	compare.Init()

	// Get the subtree of the embedded files, so we can serve it from the root.
	webFS, err := fs.Sub(embeddedFiles, "web")
	if err != nil {
		log.Fatalf("Error getting embedded web files: %v", err)
	}
	clientinterface.Listen(webFS, generic.Config.PortNo)
}
