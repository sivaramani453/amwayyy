resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "every-day-clean-es"
  description         = "Clean old es docs every day"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
  rule = "${aws_cloudwatch_event_rule.every_day.name}"
  arn  = "${module.lambda_function.func_arn}"
}
