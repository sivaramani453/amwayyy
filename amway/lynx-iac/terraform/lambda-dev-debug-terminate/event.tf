resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "every-day-run-dev-debug-terminate"
  description         = "Run dev-debug terminator every day at 19:15 UTC (21:15 CET)"
  schedule_expression = "cron(15 19 * * ? *)"
}

resource "aws_cloudwatch_event_target" "dev_debug_terminate_event_target" {
  rule = "${aws_cloudwatch_event_rule.every_day.name}"
  arn  = "${module.lambda_function.func_arn}"
}
