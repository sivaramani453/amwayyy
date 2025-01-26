module "lambda_function" {
  source = "../modules/lambda"

  filename      = "${path.module}/src/sms.zip"
  function_name = "MicroserviceSMS-UA"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.7"
  timeout       = "5"

  vpc_id  = "vpc-06f57ef6907c5b2a2"
  subnets = ["subnet-080bbbbf07082f276", "subnet-0cf578e926f5ff804", "subnet-0fde480294f2f9f62"]

  statement_id = "AllowAPIGatewayInvoke"
  principal    = "apigateway.amazonaws.com"
  arn          = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/v1/message-service/send-message"

  env_vars = {
    INFOBIP_CHANNEL      = "SMS"
    UA_GMS_API_URL       = "https://api-v2.hyber.im/3233"
    UA_GMS_USERNAME      = "Amway3_T"
    UA_GMS_PASSWORD      = "${var.provider_password}"
    language             = "uk"
  }
}
