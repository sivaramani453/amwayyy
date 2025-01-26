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

  name        = "ec2-volume-remover-lambda-sg"
  description = "Security group for the EC2 Volume remover Lambda in VPC"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "run-ec2-volume-remover-every-day"
  description         = "Run ec2 volume remover every day at 19:20 UTC (21:20 CET)"
  schedule_expression = "cron(20 19 * * ? *)"

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.every_day.name
  arn  = module.lambda_function_s3.lambda_function_arn
}

module "lambda_function_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.1.0"

  function_name                           = "EC2VolumeRemover"
  description                             = "Remove unattached ec2 volumes in the AWS"
  handler                                 = "volume_remover.handler"
  runtime                                 = "python3.8"
  timeout                                 = "180"
  memory_size                             = "256"
  reserved_concurrent_executions          = "1"
  vpc_subnet_ids                          = local.lambda_subnet_ids
  vpc_security_group_ids                  = [module.lambda_sg.this_security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.terraform_remote_state.core.outputs.s3_lambda_bucket_name
    key    = "volume_remover.zip"
  }

  allowed_triggers = {
    AllowExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.every_day.arn
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
      actions   = ["ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DescribeInstances", "ec2:DescribeVolumes", "ec2:DeleteVolume"],
      resources = ["*"]
    },
    cloudtrail_access = {
      effect    = "Allow",
      actions   = ["cloudtrail:LookupEvents"],
      resources = ["*"]
    }
  }

  environment_variables = {
    "DAYS_TO_STORE" = "5"
  }

  tags = local.amway_common_tags
}
