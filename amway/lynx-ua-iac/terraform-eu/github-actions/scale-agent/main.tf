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

  name        = "gh-scale-agent-${terraform.workspace}-lambda-sg"
  description = "Security group for the GitHub Actions scale agent Lambda in VPC"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_rule" "every_few_minutes" {
  name                = "run-gh-scale-agent-${terraform.workspace}"
  description         = "Check github actions queue every few minutes"
  schedule_expression = "rate(5 minutes)"

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.every_few_minutes.name
  arn  = module.lambda_function_s3.lambda_function_arn
}

module "lambda_function_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "1.41.0"

  function_name                           = "gh-scale-agent-${lower(terraform.workspace)}"
  description                             = "GitHub Actions scale agent"
  handler                                 = "main.lambda_handler"
  runtime                                 = "python3.8"
  timeout                                 = "900"
  memory_size                             = "1024"
  reserved_concurrent_executions          = "1"
  vpc_subnet_ids                          = local.lambda_subnet_ids
  vpc_security_group_ids                  = [module.lambda_sg.this_security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.terraform_remote_state.core.outputs.s3_lambda_bucket_name
    key    = "scale-agent.zip"
  }

  allowed_triggers = {
    AllowExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.every_few_minutes.arn
    }
  }

  attach_policies = true
  policies = [
    module.gh_scale_agent_dynamodb_access_policy.arn,
    module.gh_scale_agent_ssm_access_policy.arn,
    module.gh_scale_agent_ec2_access_policy.arn,
    module.gh_scale_agent_iam_access_policy.arn,
  ]
  number_of_policies = 4

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
    GIT_ORG   = lookup(local.git_org, terraform.workspace, local.git_org["default"])
    GIT_REPO  = lookup(local.git_repo, terraform.workspace, local.git_repo["default"])
    GIT_TOKEN = lookup(local.git_token, terraform.workspace, local.git_token["default"])

    INSTANCE_REGION    = data.aws_region.current.name
    INSTANCE_TYPE      = lookup(local.instance_type, terraform.workspace, local.instance_type["default"])
    INSTANCE_AMI       = lookup(local.instance_ami, terraform.workspace, local.instance_ami["default"])
    INSTANCE_DISK_SIZE = lookup(local.instance_disk_size, terraform.workspace, local.instance_disk_size["default"])
    INSTANCE_SUBNET    = lookup(local.instance_subnet, terraform.workspace, local.instance_subnet["default"])
    INSTANCE_KP        = lookup(local.instance_kp, terraform.workspace, local.instance_kp["default"])
    INSTANCE_SG        = lookup(local.instance_sg, terraform.workspace, local.instance_sg["default"])
    INSTANCE_PROFILE   = aws_iam_instance_profile.gh_scale_agent_instance_iam_profile.name
    DYNAMODB_REGION    = data.aws_region.current.name
    DYNAMODB_TABLE     = module.gh_scale_agent_dynamodb_table.dynamodb_table_id

    SKYPE_URL    = "${local.skype_url}"
    SKYPE_CHAN   = "${local.skype_chan}"
    SKYPE_SECRET = "${local.skype_secret}"
  }

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_log_subscription_filter" "stream_to_elk" {
  depends_on = [module.lambda_function_s3]

  name            = "gh-scale-agent-${terraform.workspace}"
  filter_pattern  = "[severity, timestamp=*Z, request_id, message]"
  log_group_name  = module.lambda_function_s3.lambda_cloudwatch_log_group_name
  destination_arn = data.aws_lambda_function.send_logs_to_elk.arn
}

module "gh_scale_agent_dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "actions-${terraform.workspace}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "k"

  attributes = [
    {
      name = "k"
      type = "S"
    }
  ]

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}
