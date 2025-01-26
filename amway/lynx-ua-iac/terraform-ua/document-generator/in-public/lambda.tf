module "lambda_function" {
  source = "../modules/lambda"

  filename      = "${path.module}/src/app.zip"
  function_name = "DocumentGeneratorInQAInternet"
  handler       = "index.handler"
  runtime       = "nodejs12.x"
  timeout       = "30"
  memory_amount = "512"

  # Network config (sec group still be created, just ignore it)
  vpc_id  = ""
  subnets = []

  statement_id = "AllowAPIGatewayInvoke"
  principal    = "apigateway.amazonaws.com"
  arn          = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/"

  env_vars = {
    "TERRAFORM" = true
  }
}
