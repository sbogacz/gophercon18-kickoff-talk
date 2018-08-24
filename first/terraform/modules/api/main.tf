data "aws_iam_policy" "AmazonDynamoDBFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "aws_iam_policy" "CloudWatchLogsFullAccess" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

module "lambda" {
  source = "./lambda"

  # Environment
  environment = "${var.environment}"
  tags        = "${var.tags}"

  # Name (should match the file name.zip)
  function_name   = "${var.lambda_function_name}"
  filepath        = "${var.lambda_function_filepath}"
  executable_name = "${var.lambda_executable_name}"
  timeout         = "${var.lambda_timeout}"

  # Dynamo policy
  attach_policies = ["${data.aws_iam_policy.AmazonDynamoDBFullAccess.arn}", "${data.aws_iam_policy.CloudWatchLogsFullAccess.arn}"]

  # X-Ray
  enable_xray  = "${var.enable_xray}"
  tracing_mode = "${var.tracing_mode}"

  # Env variables
  env_vars = "${var.lambda_env_vars}"
}

module "apigw" {
  source = "./apigw"

  # Name, description
  api_name        = "${var.api_name}"
  api_description = "${var.api_description}"

  # Environment
  environment              = "${var.environment}"
  aws_lambda_arn           = "${module.lambda.lambda_arn}"
  aws_lambda_invoke_arn    = "${module.lambda.lambda_invoke_arn}"
  aws_lambda_function_name = "${var.lambda_function_name}"
}
