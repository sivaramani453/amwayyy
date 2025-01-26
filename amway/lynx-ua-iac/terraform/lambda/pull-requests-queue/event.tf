resource "aws_cloudwatch_event_rule" "every_few_minutes" {
  name                = "run-pr-queue-${terraform.workspace}"
  description         = "Check pull request queue every few minutes"
  schedule_expression = "rate(3 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = "${aws_cloudwatch_event_rule.every_few_minutes.name}"
  arn  = "${module.lambda.func_arn}"
}
