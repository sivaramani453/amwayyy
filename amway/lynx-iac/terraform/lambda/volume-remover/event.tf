resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "every-day-run-volume-remover"
  description         = "Run volume remover every day at 19:20 UTC (21:20 CET)"
  schedule_expression = "cron(20 19 * * ? *)"
}

resource "aws_cloudwatch_event_target" "volume_remover_event_target" {
  rule = "${aws_cloudwatch_event_rule.every_day.name}"
  arn  = "${module.lambda_function.func_arn}"
}
