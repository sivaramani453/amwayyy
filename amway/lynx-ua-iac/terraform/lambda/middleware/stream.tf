data "aws_lambda_function" "send_logs_to_elk" {
  function_name = "${var.log_function_name}"
}

resource "aws_cloudwatch_log_subscription_filter" "stream_to_elk" {
  name            = "GithubLynxMiddleware-lambda-stream"
  filter_pattern  = "[timestamp=*Z, severity, requestID, message]"
  log_group_name  = "${module.lambda_function.log_group_name}"
  destination_arn = "${data.aws_lambda_function.send_logs_to_elk.arn}"
}
