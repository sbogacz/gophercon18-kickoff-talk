# API GW Terraform Module

This is a small terraform module to create an AWS API Gateway that connects to a
Lambda (using the given ARN)

## Variables

* environment: string
* aws_lambda_arn: string (the identifying ARN)
* aws_lambda_invoke_arn: string (the ARN that can be used for invocation, e.g. with API GW)

## Outputs
* api_url: string
