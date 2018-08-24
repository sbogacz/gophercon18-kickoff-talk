output "api_url" {
  value = "${aws_api_gateway_deployment.apigw_deploy.invoke_url}"
}
