data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "lambda_function" {
  source = "../../modules/lambda"

  function_name = "ZabbixDiscovery"
  s3_bucket     = "${data.terraform_remote_state.core.s3_lambda_bucket_name}"
  s3_key        = "zbx.zip"

  handler            = "zbx"
  runtime            = "go1.x"
  timeout            = "30"
  custom_tags_common = "${var.custom_tags_common}"

  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.every_5_min.arn}"

  env_vars = {
    "ZABBIX_URL"      = "http://zabbix.hybris.eia.amway.net/api_jsonrpc.php"
    "ZABBIX_USER"     = "Admin"
    "ZABBIX_PASSWORD" = "${var.zabbix_password}"
    "WHEN_MISSING"    = "disable"
  }
}
