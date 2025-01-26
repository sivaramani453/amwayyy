data "aws_lambda_function" "send_logs_to_elk" {
  function_name = "SendLogsToElasticsearch"
}

resource "aws_cloudwatch_log_subscription_filter" "stream_to_elk" {
  depends_on = ["module.lambda_function"]

  name            = "ZabbixDiscovery-lambda-stream"
  filter_pattern  = "[timestamp=*Z, severity, requestID, message]"
  log_group_name  = "${module.lambda_function.log_group_name}"
  destination_arn = "${data.aws_lambda_function.send_logs_to_elk.arn}"
}
