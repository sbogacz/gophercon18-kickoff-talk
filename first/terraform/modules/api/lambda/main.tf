# The IAM role the lambda function will need
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-lambda_exec_role"

  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Principal": {
				"Service": "lambda.amazonaws.com"
			},
			"Effect": "Allow",
			"Sid": ""
		}
	]
}
EOF
}

# Access policy if in a VPC
data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Access policy for X-Ray writes
data "aws_iam_policy" "AWSXrayWriteOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

# Attach X-Ray policy if enabled
resource "aws_iam_role_policy_attachment" "xray_attach" {
  count      = "${var.enable_xray ? 1 : 0}"
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${data.aws_iam_policy.AWSXrayWriteOnlyAccess.arn}"
}

# if we were given additional policies to attach (e.g. RDS, Dynamo, etc.)
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  count      = "${length(var.attach_policies)}"
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${element(var.attach_policies, count.index)}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "${var.filepath}"
  function_name    = "${var.function_name}"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "${var.executable_name}"
  source_code_hash = "${base64sha256(file("${var.filepath}"))}"
  runtime          = "go1.x"
  memory_size      = "${var.memory_size}"
  timeout          = "${var.timeout}"
  tags             = "${var.tags}"

  tracing_config {
    mode = "${var.tracing_mode}"
  }

  environment {
    variables = "${var.env_vars}"
  }
}
