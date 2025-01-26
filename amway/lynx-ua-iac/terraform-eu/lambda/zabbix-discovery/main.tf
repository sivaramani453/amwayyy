data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_lambda_function" "send_logs_to_elk" {
  function_name = "SendLogsToElasticsearch"
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "lambda_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sendlogs-lambda-sg"
  description = "Security group for the ElasticSearchCurator Lambda in VPC"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_rule" "every_5_min" {
  name                = "run-zabbix-host-discovery"
  description         = "Discover ec2 instances by a tag and add them to zabbix"
  schedule_expression = "rate(2 minutes)"

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_target" "every_5_min" {
  rule = aws_cloudwatch_event_rule.every_5_min.name
  arn  = module.lambda_function_s3.lambda_function_arn
}

module "lambda_function_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.1.0"

  function_name                           = "ZabbixDiscovery"
  description                             = "Discover ec2 instances by a tag in the AWS Account and add them to zabbix"
  handler                                 = "zabbixdiscovery"
  runtime                                 = "go1.x"
  timeout                                 = "30"
  vpc_subnet_ids                          = local.lambda_subnet_ids
  vpc_security_group_ids                  = [module.lambda_sg.this_security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.terraform_remote_state.core.outputs.s3_lambda_bucket_name
    key    = "zabbixdiscovery.zip"
  }

  allowed_triggers = {
    AllowExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.every_5_min.arn
    }
  }

  attach_policy_statements = true
  policy_statements = {
    write_cloudwatch_logs = {
      effect    = "Allow",
      actions   = ["logs:CreateLogGroup"],
      resources = ["*"]
    },
    ec2_access = {
      effect    = "Allow",
      actions   = ["ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DescribeInstances"],
      resources = ["*"]
    }
  }

  environment_variables = {
    "ZABBIX_URL"      = "http://zabbix.hybris.eu.eia.amway.net/api_jsonrpc.php"
    "ZABBIX_USER"     = "Admin"
    "ZABBIX_PASSWORD" = "${var.zabbix_password}"
    "WHEN_MISSING"    = "disable"
  }

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_log_subscription_filter" "stream_to_elk" {
  depends_on = [module.lambda_function_s3]

  name            = "ZabbixDiscovery-lambda-stream"
  filter_pattern  = "[timestamp=*Z, severity, requestID, message]"
  log_group_name  = module.lambda_function_s3.lambda_cloudwatch_log_group_name
  destination_arn = data.aws_lambda_function.send_logs_to_elk.arn
}
