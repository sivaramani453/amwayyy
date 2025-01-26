locals {
  env_vars = "${var.env_vars}"
  key      = "${var.vpc_id == "" ? "0" : "1"}"
  items    = "${map("0", "", "1", aws_security_group.lambda.id)}"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = "${var.logs_retention}"
}

resource "aws_lambda_function" "main" {
  filename      = "${var.filename}"
  function_name = "${var.function_name}"
  role          = "${aws_iam_role.lambda-role.arn}"
  handler       = "${var.handler}"
  runtime       = "${var.runtime}"
  timeout       = "${var.timeout}"
  memory_size   = "${var.memory_amount}"

  vpc_config {
    subnet_ids         = ["${var.subnets}"]
    security_group_ids = ["${lookup(local.items, local.key)}"]
  }

  environment {
    variables = "${local.env_vars}"
  }
}

resource "aws_lambda_permission" "allow_to_invoke" {
  statement_id  = "${var.statement_id}"
  action        = "lambda:InvokeFunction"
  principal     = "${var.principal}"
  function_name = "${aws_lambda_function.main.function_name}"
  source_arn    = "${var.arn}"
}
