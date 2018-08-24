resource "aws_api_gateway_rest_api" "apigw" {
  name        = "${var.api_name}-${var.environment}"
  description = "${var.api_description}"
}

# match all the path using proxy
resource "aws_api_gateway_resource" "apigw_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  parent_id   = "${aws_api_gateway_rest_api.apigw.root_resource_id}"
  path_part   = "{proxy+}"
}

# ANY on the above proxy resource
resource "aws_api_gateway_method" "apigw_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.apigw.id}"
  resource_id   = "${aws_api_gateway_resource.apigw_proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

# connect lambda to the ANY proxy above
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  resource_id = "${aws_api_gateway_method.apigw_proxy.resource_id}"
  http_method = "${aws_api_gateway_method.apigw_proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.aws_lambda_invoke_arn}"
}

# ANY on the root resource
resource "aws_api_gateway_method" "apigw_proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.apigw.id}"
  resource_id   = "${aws_api_gateway_rest_api.apigw.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

# connect lambda to the ANY proxy above
resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  resource_id = "${aws_api_gateway_method.apigw_proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.apigw_proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.aws_lambda_invoke_arn}"
}

# create API Gateway deployment
resource "aws_api_gateway_deployment" "apigw_deploy" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  stage_name  = "${var.environment}"
}

# allow API Gateway to trigger lambda from any stage/verb/url
resource "aws_lambda_permission" "apigw_lambda_trigger" {
  statement_id  = "${var.api_name}_can_trigger_${var.aws_lambda_function_name}"
  action        = "lambda:InvokeFunction"
  function_name = "${var.aws_lambda_arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.apigw_deploy.execution_arn}/*/*"
}
