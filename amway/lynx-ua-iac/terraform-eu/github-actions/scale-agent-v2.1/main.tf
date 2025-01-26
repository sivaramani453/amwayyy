
# resource "aws_cloudwatch_event_rule" "every_few_minutes" {
#   name                = "run-gh-scale-agent-v2-${terraform.workspace}"
#   description         = "Check github actions queue every few minutes"
#   schedule_expression = "rate(5 minutes)"
# }
