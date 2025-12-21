package database

import (
	"fmt"
	"intDocument/server/config"

	"go.mills.io/bitcask/v2"
)

var db *bitcask.Bitcask

func Connect() (string, bool) {
	var err error
	opts := []bitcask.Option{
		bitcask.WithMaxValueSize(1024 * 1024 * 1024),
	}
	db, err = bitcask.Open(config.Config.DatabasePath, opts...)
	if err != nil {
		fmt.Println("error opening database", err.Error())
		return err.Error(), false
	}
	return "", true
}
