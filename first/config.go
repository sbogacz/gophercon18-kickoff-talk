package main

import (
	"fmt"
	"log"
	"os"
)

type config struct {
	BucketName string
	Salt       string
}

func (c *config) ParseEnv() {
	c.BucketName = os.Getenv("BUCKET_NAME")
	c.Salt = os.Getenv("SALT")

	if c.BucketName == "" {
		log.Fatal("bucket name must be specified")
	}
	if c.Salt == "" {
		log.Fatal("a salt value must be provided")
	}
}

func flagName(name string) string {
	return fmt.Sprintf("EXAMPLE_APP_%s", name)
}
