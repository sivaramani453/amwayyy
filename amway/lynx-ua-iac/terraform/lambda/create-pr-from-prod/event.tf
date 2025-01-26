resource "aws_cloudwatch_event_rule" "trigger_check" {
  name                = "check-prod-branch-${terraform.workspace}"
  description         = "Check if prod branch is updated"
  schedule_expression = "rate(3 minutes)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_three_minutes" {
  rule = "${aws_cloudwatch_event_rule.trigger_check.name}"
  arn  = "${module.lambda_function.func_arn}"
}
