resource "aws_api_gateway_rest_api" "middleware" {
  name        = "gh-middleware-${terraform.workspace}-v2"
  description = "Terraform managed github middleware v2"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.middleware.id}"
  resource_id   = "${aws_api_gateway_rest_api.middleware.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.middleware.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${module.lambda_function.invoke_arn}"
}

resource "aws_api_gateway_deployment" "lambda_deployment" {
  depends_on = ["aws_api_gateway_integration.lambda_root"]

  rest_api_id = "${aws_api_gateway_rest_api.middleware.id}"
  stage_name  = "middleware"
}
