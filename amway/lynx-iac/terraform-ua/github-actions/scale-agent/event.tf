resource "aws_cloudwatch_event_rule" "every_few_minutes" {
  name                = "scale-agent-${terraform.workspace}"
  description         = "Check github actions queue every few minutes"
  schedule_expression = "rate(2 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = "${aws_cloudwatch_event_rule.every_few_minutes.name}"
  arn  = "${module.lambda.func_arn}"
}
