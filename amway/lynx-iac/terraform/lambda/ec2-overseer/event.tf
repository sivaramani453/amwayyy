resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "every-day-run-overseer"
  description         = "Run EC2 overseer every day"
  schedule_expression = "cron(00 7,14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "ec2_overseer_event_target" {
  rule = "${aws_cloudwatch_event_rule.every_day.name}"
  arn  = "${module.lambda_function.func_arn}"
}
