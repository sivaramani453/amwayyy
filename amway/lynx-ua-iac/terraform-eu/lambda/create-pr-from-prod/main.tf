data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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

  name        = "check-prod-branch-${terraform.workspace}-lambda-sg"
  description = "Security group for the CheckProdBranch Lambda in VPC"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_rule" "every_few_minutes" {
  name                = "run-check-prod-branch-${terraform.workspace}"
  description         = "Check every few minutes if prod branch has been updated"
  schedule_expression = "rate(3 minutes)"

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.every_few_minutes.name
  arn  = module.lambda_function_s3.lambda_function_arn
}

module "lambda_function_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.1.0"

  function_name                           = "CheckProdBranch${upper(terraform.workspace)}"
  description                             = "Check prod branch for updates"
  handler                                 = "main.lambda_handler"
  runtime                                 = "python3.8"
  timeout                                 = "120"
  memory_size                             = "128"
  reserved_concurrent_executions          = "1"
  vpc_subnet_ids                          = local.lambda_subnet_ids
  vpc_security_group_ids                  = [module.lambda_sg.this_security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.terraform_remote_state.core.outputs.s3_lambda_bucket_name
    key    = "create-prs.zip"
  }

  allowed_triggers = {
    AllowExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.every_few_minutes.arn
    }
  }

  attach_policies = true
  policies = [
    module.check_prod_branch_ssm_access_policy.arn,
  ]
  number_of_policies = 1

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
    REF                 = "prod"
    ORG                 = "AmwayACS"
    GITHUB_API_TOKEN    = "${var.git_token}"
    CODE_REPO           = "${local.code_repo[terraform.workspace]}"
    CONFIG_REPO         = "${local.config_repo[terraform.workspace]}"
    PARAMETER_LYNX      = "${aws_ssm_parameter.commit_sha_lynx.name}"
    PARAMETER_LYNX_CONF = "${aws_ssm_parameter.commit_sha_lynx_conf.name}"
    BRANCHES            = "${local.branches[terraform.workspace]}"
    TEAMS_CHANNEL       = "${local.teams_channel[terraform.workspace]}"
  }

  tags = local.amway_common_tags
}
