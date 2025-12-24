package config

import (
	"encoding/json"
	"fmt"
	"os"
)

// Configuration structure defines the available config options
type Configuration struct {
	PortNo       string `json:"PortNo"`
	DatabasePath string `json:"DatabasePath"`
	LogPath      string `json:"LogPath"`
	BasePath     string `json:"BasePath"`
}

// Global Config variable
var Config Configuration

// ReadConfiguration reads the config file at the given path
func ReadConfiguration(path string) error {
	file, err := os.Open(path)
	if err != nil {
		return fmt.Errorf("failed to open config file: %w", err)
	}
	defer file.Close()

	decoder := json.NewDecoder(file)
	err = decoder.Decode(&Config)
	if err != nil {
		return fmt.Errorf("failed to decode config file: %w", err)
	}
	fmt.Printf("Config: %+v\n ", Config)
	return nil
}
