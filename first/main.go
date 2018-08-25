// +build OMIT

package main

import (
	"context"
	"crypto/sha256"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"

	log "github.com/Sirupsen/logrus"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/aws/awserr"
	"github.com/aws/aws-sdk-go-v2/aws/external"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/pkg/errors"
)

var (
	s3Client *s3.S3
	cfg      = &config{}
)

func handler(ctx context.Context, req *events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	var data string
	var key string
	var err error
	// SWITCH OMIT
	switch req.HTTPMethod { // HL
	case "POST":
		key, err = postFile(ctx, req.Body)
	case "GET":
		key, err = extractKey(req)
		if err != nil {
			return nil, err
		}

		data, err = getFile(ctx, key)
	case "DELETE":
		key, err = extractKey(req)
		if err != nil {
			return nil, err
		}

		err = deleteFile(ctx, key)
	}
	// ENDSWITCH OMIT
	if err != nil {
		log.WithError(err).Error("failed to process request")
		return errorResponse(err), err
	}
	body := key
	if data != "" {
		body = data
	}
	return &events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Body:       body,
	}, nil
}

func main() {
	awsCfg, err := external.LoadDefaultAWSConfig()
	if err != nil {
		log.Fatal("failed to load config")
	}

	log.SetLevel(log.DebugLevel)

	s3Client = s3.New(awsCfg)

	cfg.ParseEnv()
	lambda.Start(handler)
}

func postFile(ctx context.Context, data string) (string, error) {
	key := generateKey(data)
	input := putInput(key, data)

	log.Infof("going to try a put %+v", input)
	putReq := s3Client.PutObjectRequest(input)
	_, err := putReq.Send()
	if err != nil {
		return "", errors.Wrap(err, "failed to put file in S3")
	}
	return key, nil
}

func getFile(ctx context.Context, key string) (string, error) {
	input := getInput(key)
	getReq := s3Client.GetObjectRequest(input)
	resp, err := getReq.Send()
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			if aerr.Code() == s3.ErrCodeNoSuchKey {
				return "", newNotFoundErr(err, "no such file")
			}
		}
		return "", newInternalServerErr(err, "failed to get file from S3")
	}

	defer resp.Body.Close()
	b, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", newInternalServerErr(err, "failed to read object body")
	}
	return string(b), nil
}

func deleteFile(ctx context.Context, key string) error {
	input := deleteInput(key)
	deleteReq := s3Client.DeleteObjectRequest(input)
	_, err := deleteReq.Send()
	if err != nil {
		return newInternalServerErr(err, "failed to delete file from S3")
	}
	return nil
}

func putInput(key, data string) *s3.PutObjectInput {
	return &s3.PutObjectInput{
		Bucket:               aws.String(cfg.BucketName),
		Key:                  aws.String(key),
		ServerSideEncryption: s3.ServerSideEncryptionAes256,
		Body:                 aws.ReadSeekCloser(strings.NewReader(data)),
	}
}

func getInput(key string) *s3.GetObjectInput {
	return &s3.GetObjectInput{
		Bucket: aws.String(cfg.BucketName),
		Key:    aws.String(key),
	}
}

func deleteInput(key string) *s3.DeleteObjectInput {
	return &s3.DeleteObjectInput{
		Bucket: aws.String(cfg.BucketName),
		Key:    aws.String(key),
	}
}

func generateKey(data string) string {
	h := sha256.New()
	io.WriteString(h, cfg.Salt)
	io.WriteString(h, data)
	return url.PathEscape(string(h.Sum(nil)))
}

func extractKey(req *events.APIGatewayProxyRequest) (string, error) {
	pathParams := strings.Split(req.Path, "/")
	if len(pathParams) < 2 {
		return "", newBadRequestErr(errors.Errorf("no file specified"), "")
	}
	if len(pathParams) > 2 {
		return "", newBadRequestErr(errors.Errorf("invalid path selection"), "")
	}
	return pathParams[1], nil
}
