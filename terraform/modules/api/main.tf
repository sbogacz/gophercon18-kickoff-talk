module "store" {
  source = "s3"

  bucket_name       = "${var.bucket_name}"
  enable_expiration = "${var.enable_expiration}"
  ttl               = "${var.ttl}"

  environment = "${var.environment}"
  tags        = "${var.tags}"
}

resource "aws_iam_policy" "lambda_s3_access" {
  name = "${format("%s_lambda_access", var.bucket_name)}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${module.store.bucket_arn}"
      ]
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${module.store.bucket_arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "lambda_s3_access" {
  name       = "${format("%s_lambda_access", var.bucket_name)}"
  roles      = ["${module.lambda.role_name}"]
  policy_arn = "${aws_iam_policy.lambda_s3_access.arn}"
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

  # X-Ray
  enable_xray  = "${var.enable_xray}"
  tracing_mode = "${var.tracing_mode}"

  # Env variables
  env_vars = "${merge(map("BUCKET_NAME", module.store.bucket_name), var.lambda_env_vars)}"
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
