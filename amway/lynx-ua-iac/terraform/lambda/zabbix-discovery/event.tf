resource "aws_cloudwatch_event_rule" "every_5_min" {
  name                = "run_zabbix_host_discovery"
  description         = "Discover hosts in ec2 to add to zabbix"
  schedule_expression = "rate(2 minutes)"

  tags = {
    Terraform = "true"
  }
}

resource "aws_cloudwatch_event_target" "check_every_five_minutes" {
  rule = "${aws_cloudwatch_event_rule.every_5_min.name}"
  arn  = "${module.lambda_function.func_arn}"
}
