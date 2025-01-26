output "stage_url" {
  value = "${aws_api_gateway_deployment.lambda_deployment.invoke_url}"
}

output "api_key" {
  value = "${aws_api_gateway_api_key.docgen.value}"
}
