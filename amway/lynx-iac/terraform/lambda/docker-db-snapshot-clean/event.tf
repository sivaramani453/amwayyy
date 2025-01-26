resource "aws_cloudwatch_event_rule" "every_fifth_day" {
  name                = "every-fifth-day-run-docker-db-snapshot-cleanup"
  description         = "Run docker-db-snapshot cleanup every fifth day of the month at 00:00 UTC (23:00 CET)"
  schedule_expression = "cron(0 0 */5 * ? *)"
}

resource "aws_cloudwatch_event_target" "docker_db_snapshot_cleanup_event_target" {
  rule = "${aws_cloudwatch_event_rule.every_fifth_day.name}"
  arn  = "${module.lambda_function.func_arn}"
}
