data "aws_lambda_function" "send_logs_to_elk" {
  function_name = "SendDocGenEuQALogs"
}

resource "aws_cloudwatch_log_subscription_filter" "stream_to_elk" {
  name            = "DocGen-lambda-stream"
  filter_pattern  = "[timestamp=*Z, request_id=\"*-*\", event]"
  log_group_name  = "${module.lambda_function.log_group_name}"
  destination_arn = "${data.aws_lambda_function.send_logs_to_elk.arn}"
}
