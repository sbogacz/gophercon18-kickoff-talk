package main

import (
	"flag"
	"fmt"
)

type config struct {
	BucketName string
	Salt       string
}

func (c *config) ParseEnv() {
	flag.StringVar(&c.BucketName, flagName("BUCKET_NAME"), "", "the S3 bucket name to use for the application")
	flag.StringVar(&c.Salt, flagName("SALT"), "", "the S3 bucket name to use for the application")
	flag.Parse()
}

func flagName(name string) string {
	return fmt.Sprintf("EXAMPLE_APP_%s", name)
}
