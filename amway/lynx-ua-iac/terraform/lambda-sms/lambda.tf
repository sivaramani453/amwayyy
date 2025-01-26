module "lambda_function" {
  source = "../modules/lambda"

  filename      = "${path.module}/src/sms.zip"
  function_name = "MicroserviceSMS"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python2.7"
  timeout       = "5"

  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}", "${data.terraform_remote_state.core.subnet.core_c.id}"]

  statement_id = "AllowAPIGatewayInvoke"
  principal    = "apigateway.amazonaws.com"
  arn          = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/v1/message-service/send-message"

  env_vars = {
    INFOBIP_CHANNEL     = "OMNI"
    RU_INFOBIP_USERNAME = "Amway-MZ"
    RU_INFOBIP_PASSWORD = "${var.ru_infobip_password}"
    RU_INFOBIP_URL      = "https://164rx.api.infobip.com/"
    RU_SCENARIO_KEY     = "5750AD21476C64979E2CF0234A54290F"
    KZ_INFOBIP_USERNAME = "Amway-MZ"
    KZ_INFOBIP_PASSWORD = "${var.kz_infobip_password}"
    KZ_INFOBIP_URL      = "https://164rx.api.infobip.com/"
    KZ_SCENARIO_KEY     = "5750AD21476C64979E2CF0234A54290F"
  }
}
