output "vpc_endpoint_url" {
  value = "https://${data.terraform_remote_state.core.frankfurt_dns_vpc_endpoint_public_all}"
}

output "lambda_invoke_arn" {
  value = "${module.lambda_function.invoke_arn}"
}

output "stage_url" {
  value = "${aws_api_gateway_deployment.lambda_deployment.invoke_url}"
}
