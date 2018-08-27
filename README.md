# gophercon18-kickoff-talk
Code and slides for the 2018 Gophercon Kickoff Party talk at SendGrid

## Goal

We're trying to build a simpler K/V style service for 1 day-lived object storage and retrieval, and we're planning to do it using AWS: namely Lambda, API Gateway, and S3.

## First

The first part of the material approaches the problem like a POC. Our code is tightly coupled to the platform we're running on. Even using [Terraform](https://terraform.io) to deploy our code it's still 30 seconds just to deploy, let alone test

## Second

The second part of the talk introduces [localstack](https://github.com/localstack/localstack). However, a Terraform provider AWS bug means that we have to do a lot of legwork to manually create our stack

## Third

In the third part we decide to make our code more agnostic of the platform it's running on. We interface the store and provide a local implementation, and write a standard HTTP server. We leverage [AWS Labs' Lambda Go Proxy library](https://github.com/awslabs/aws-lambda-go-api-proxy) so that we only translate in our `cmd/lambda/main.go` file, leaving the rest of our code blissfully ignorant of that implementation detail. We also get a binary to run our app locally, to allow us to do business logic validation without needing a full deploy

## Fourth

In the fourth parth we take the next step in abstracting our backend and replace our `Store` interface with [go-cloud's](https://github.com/google/go-cloud) [blob.Bucket](https://godoc.org/github.com/google/go-cloud/blob#Bucket). Not only do we get to delete some of the code we wrote in the Third part, but we also get additional flexibility in terms of our storage provider to go with our server platform agnosticism.
