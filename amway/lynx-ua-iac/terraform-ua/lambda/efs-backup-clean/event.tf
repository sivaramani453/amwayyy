resource "aws_cloudwatch_event_rule" "efs_every_month" {
  name                = "every-month-run-efs-backup-cleanup-${terraform.workspace}"
  description         = "Run efs-backup cleanup on the 1-st day of the month at 01:00 UTC (00:00 CET)"
  schedule_expression = "cron(0 1 1 * ? *)"
}

resource "aws_cloudwatch_event_target" "efs_backup_cleanup_event_target" {
  rule = "${aws_cloudwatch_event_rule.efs_every_month.name}"
  arn  = "${module.lambda_function.func_arn}"
}
