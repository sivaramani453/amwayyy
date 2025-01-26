data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "lambda_function" {
  source = "../../modules/lambda"

  filename      = "${path.module}/src/log.zip"
  function_name = "SendLogsToSplunk"
  handler       = "log"
  runtime       = "go1.x"
  timeout       = "30"
  env_vars      = "${merge(var.env_vars, map("SPLUNK_TOKEN", var.splunk_token) )}"

  # Network config

  vpc_id  = ""
  subnets = []
  # invoke permission
  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "logs.${data.aws_region.current.name}.amazonaws.com"
  arn          = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*:*:*"
}
