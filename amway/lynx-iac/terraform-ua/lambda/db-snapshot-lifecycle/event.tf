resource "aws_cloudwatch_event_rule" "every_fourth_day" {
  name                = "every-fourth-day-run-db-snapshot-lifecycle"
  description         = "Run db_snapshot_lifecycle cleanup every fourth day of the month at 00:00 UTC (23:00 CET)"
  schedule_expression = "cron(0 0 */4 * ? *)"
}

resource "aws_cloudwatch_event_target" "db_snapshot_lifecycle_event_target" {
  rule = "${aws_cloudwatch_event_rule.every_fourth_day.name}"
  arn  = "${module.lambda_function.func_arn}"
}
