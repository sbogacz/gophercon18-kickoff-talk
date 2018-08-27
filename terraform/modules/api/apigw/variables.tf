variable "environment" {
  description = "development, production, etc."
  type        = "string"
  default     = "development"
}

variable "aws_lambda_arn" {
  description = "the ARN of the lambda you wish to invoke with the gateway"
  type        = "string"
}

variable "aws_lambda_function_name" {
  description = "the name of the lambda you wish to invoke with the gateway"
  type        = "string"
}

variable "aws_lambda_invoke_arn" {
  description = "the invoke ARN of the lambda you wish to invoke with the gateway"
  type        = "string"
}

variable "api_name" {
  description = "the name of the API the Gateway is being created for"
  type        = "string"
}

variable "api_description" {
  description = "a description for the API being created"
  type        = "string"
}
