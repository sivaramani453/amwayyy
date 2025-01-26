module "lambda_function" {
  source = "../modules/lambda"

  filename      = "${path.module}/src/sms.zip"
  function_name = "MicroserviceSMS-UA"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.7"
  timeout       = "5"

  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}", "${data.terraform_remote_state.core.subnet.core_c.id}"]

  statement_id = "AllowAPIGatewayInvoke"
  principal    = "apigateway.amazonaws.com"
  arn          = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/v1/message-service/send-message"

  env_vars = {
    PROVIDER_CHANNEL     = "OMNI"
    PROVIDER_USERNAME    = "Amway-MZ"
    PROVIDER_PASSWORD    = "${var.provider_password}"
    PROVIDER_URL         = "https://164rx.api.infobip.com/"
    PROVIDER_KEY         = "5750AD21476C64979E2CF0234A54290F"
  }
}
