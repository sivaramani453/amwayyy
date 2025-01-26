resource "aws_api_gateway_rest_api" "scaleapi" {
  name        = "gh-scale-agent-v2-${terraform.workspace}-apigw"
  description = "Terraform managed github apigw scale agent v2"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.scaleapi.id
  resource_id   = aws_api_gateway_rest_api.scaleapi.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
#  api_key_required = true
}

resource "aws_api_gateway_method_settings" "post_settings" {
  rest_api_id = aws_api_gateway_rest_api.scaleapi.id
  stage_name  = "scaleapi_${terraform.workspace}"
  method_path = "*/*"
  settings {
    logging_level = "INFO"
    data_trace_enabled = false
    metrics_enabled = false
  }
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.scaleapi.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_function_s3.lambda_function_invoke_arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
}

resource "aws_api_gateway_deployment" "lambda_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_root]

  rest_api_id = aws_api_gateway_rest_api.scaleapi.id
  stage_name  = "scaleapi_${terraform.workspace}"
}