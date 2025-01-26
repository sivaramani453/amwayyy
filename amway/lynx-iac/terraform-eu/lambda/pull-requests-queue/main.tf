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

  name        = "pr-queue-${terraform.workspace}-lambda-sg"
  description = "Security group for the PullRequestQueue Lambda in VPC"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_rule" "every_few_minutes" {
  name                = "run-pr-queue-${terraform.workspace}"
  description         = "Check pull request queue every few minutes"
  schedule_expression = "rate(4 minutes)"

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.every_few_minutes.name
  arn  = module.lambda_function_s3.lambda_function_arn
}

module "lambda_function_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.1.0"

  function_name                           = "PullRequestQueue${upper(terraform.workspace)}"
  description                             = "Pull request queue manager"
  handler                                 = "main.lambda_handler"
  runtime                                 = "python3.9"
  timeout                                 = "300"
  memory_size                             = "128"
  reserved_concurrent_executions          = "1"
  vpc_subnet_ids                          = local.lambda_subnet_ids
  vpc_security_group_ids                  = [module.lambda_sg.this_security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.terraform_remote_state.core.outputs.s3_lambda_bucket_name
    key    = "pull-requests-queue.zip"
  }

  allowed_triggers = {
    AllowExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.every_few_minutes.arn
    }
  }

  attach_policies = true
  policies = [
    module.pr_queue_dynamodb_access_policy.arn,
    module.pr_queue_ssm_access_policy.arn
  ]
  number_of_policies = 2

  attach_policy_statements = true
  policy_statements = {
    write_cloudwatch_logs = {
      effect    = "Allow",
      actions   = ["logs:CreateLogGroup"],
      resources = ["*"]
    },
    ec2_access = {
      effect    = "Allow",
      actions   = ["ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces"],
      resources = ["*"]
    }
  }

  environment_variables = {
    REGION         = "${terraform.workspace}"
    GIT_TOKEN      = "${local.git_token[terraform.workspace]}"
    SKYPE_SECRET   = "${var.skype_secret}"
    TEAMS_SECRET   = "${local.teams_secret[terraform.workspace]}"
    DYNAMODB_TABLE = "${var.dynamodb_table}"
  }

  tags = local.amway_common_tags
}

resource "aws_ssm_parameter" "ssm_branches" {
  count = length(local.branches_list[lower(terraform.workspace)])
  name  = "locked-${terraform.workspace}-${element(local.branches_list[terraform.workspace], count.index)}"
  type  = "String"
  value = "False"

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_log_subscription_filter" "stream_to_elk" {
  depends_on = [module.lambda_function_s3]

  name            = "pr-queue-${terraform.workspace}"
  filter_pattern  = "[severity, timestamp=*Z, request_id, message]"
  log_group_name  = module.lambda_function_s3.lambda_cloudwatch_log_group_name
  destination_arn = data.aws_lambda_function.send_logs_to_elk.arn
}
