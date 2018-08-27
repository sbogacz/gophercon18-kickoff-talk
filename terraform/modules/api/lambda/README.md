# AWS Lambda Terraform Module

This creates a go1.x Terraform resource. It is not based on any external modules (yet)


## Variables
* lambda_iam_role_arn: string
  	* pre-existing iam role to give lambda rds/vpc/cloudwatch permissions etc.
* environment: string
  	* development, production, etc.
* tags: map
  	* mandatory tags to prevent Krampus from our killing services
* function_name: string
  	* name of the lambda function to deploy... should match the name of the zip file (i.e. [function_name].zip)
* filepath: string
  	* file path to the zip file that we want to deploy	
* executable_name: string
  	* name of the executable. Will default to main
* db_addr: string
  	* address of the database for the template and version tables
* db_pwd: string
  	* password for the database that holds the template and version tables
* db_user: string
  	* the user for the database
* env_vars: map
  * a map of the environment variables you want your lambda to have access to at runtime


## Outputs
* lambda_arn: string (the identifying ARN)
* lambda_invoke_arn: string (the ARN that can be used for invocation, e.g. with API GW)
