module "lambda_function" {
  source = "../modules/lambda"

  filename      = "${path.module}/src/sms.zip"
  function_name = "MicroserviceSMS-UA"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.7"
  timeout       = "5"

  vpc_id  = "${data.terraform_remote_state.core.frankfurt_preprod_vpc_id}"
 # subnets = ["${data.terraform_remote_state.core.frankfurt_subnet_lambda_a_id}", "${data.terraform_remote_state.core.frankfurt_subnet_lambda_b_id}", "${data.terraform_remote_state.core.frankfurt_subnet_lambda_c_id}"]
   subnets =  ["${data.terraform_remote_state.core.frankfurt_subnet_lambda_b_id}", "${data.terraform_remote_state.core.frankfurt_subnet_lambda_c_id}"]


  statement_id = "AllowAPIGatewayInvoke"
  principal    = "apigateway.amazonaws.com"
  arn          = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/v1/message-service/send-message"

  env_vars = {
    PROVIDER_CHANNEL     = "OMNI"
    PROVIDER_KEY         = "5750AD21476C64979E2CF0234A54290F"
    UA_GMS_PASSWORD = "${var.provider_password}"
    UA_GMS_API_URL = "https://api-v2.hyber.im/3233"
    UA_GMS_USERNAME = "Amway3_T"
    INFOBIP_CHANNEL = "SMS"
  }
}
