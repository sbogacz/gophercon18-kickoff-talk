package main

import (
	"context"
	"io/ioutil"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/google/go-cloud/blob"
	"github.com/google/go-cloud/blob/fileblob"
	"github.com/google/go-cloud/blob/s3blob"
	"github.com/pkg/errors"
	"github.com/sbogacz/gophercon18-kickoff-talk/fourth/internal/toy"
	"github.com/urfave/cli"
)

var (
	config     = &toy.Config{}
	s          *toy.Server
	localStore bool
)

func flags() []cli.Flag {
	return append(config.Flags(),
		cli.BoolFlag{
			Name:        "local-store",
			Usage:       "use an in-memory backing store",
			Destination: &localStore,
		})
}

func main() {
	app := cli.NewApp()
	app.Usage = "this is the CLI version of our toy app"
	app.Flags = flags()
	app.Action = serve

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}

func serve(c *cli.Context) error {
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	var store *blob.Bucket
	var cleanup func()
	var err error
	if localStore {
		store, cleanup, err = getLocalStore()
	} else {
		store, cleanup, err = getS3Store()
	}
	if err != nil {
		return errors.Wrap(err, "failed to initialize store")
	}
	defer cleanup()
	s = toy.New(config, store)
	go s.Start()

	<-sigs
	s.Stop()
	return nil
}

func getLocalStore() (*blob.Bucket, func(), error) {
	dir, err := ioutil.TempDir("", "toy-test-files")
	if err != nil {
		return nil, nil, err
	}
	store, err := fileblob.NewBucket(dir)
	if err != nil {
		return nil, nil, errors.Wrap(err, "failed to initialize local store")
	}
	return store, func() { os.RemoveAll(dir) }, nil
}

func getS3Store() (*blob.Bucket, func(), error) {
	noop := func() {
		return
	}
	cfg := &aws.Config{
		Credentials: credentials.NewEnvCredentials(),
	}
	sess := session.Must(session.NewSession(cfg))
	store, err := s3blob.OpenBucket(context.TODO(), sess, config.BucketName)
	if err != nil {
		return nil, nil, err
	}
	return store, noop, nil
}
