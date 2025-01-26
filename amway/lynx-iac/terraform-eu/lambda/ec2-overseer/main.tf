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

  name        = "ec2-overseer-lambda-sg"
  description = "Security group for the EC2 Overseer Lambda in VPC"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "run-ec2-overseer-every-day"
  description         = "Run EC2 overseer every day"
  schedule_expression = "cron(00 7,14 * * ? *)"

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.every_day.name
  arn  = module.lambda_function_s3.lambda_function_arn
}

module "lambda_function_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.1.0"

  function_name                           = "EC2Overseer"
  description                             = "Check for EC2 instances without a Schedule tag"
  handler                                 = "ec2_overseer.handler"
  runtime                                 = "python3.8"
  timeout                                 = "30"
  vpc_subnet_ids                          = local.lambda_subnet_ids
  vpc_security_group_ids                  = [module.lambda_sg.this_security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.terraform_remote_state.core.outputs.s3_lambda_bucket_name
    key    = "ec2_overseer.zip"
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
      actions   = ["ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DescribeInstances"],
      resources = ["*"]
    }
  }

  environment_variables = {
    "RUN_LIMIT_SEC"         = "${var.RUN_LIMIT_SEC}"
    "MESSAGE_CHAT_NAME"     = "${var.MESSAGE_CHAT_NAME}"
    "MESSAGE_CHAT_PASSWORD" = "${var.MESSAGE_CHAT_PASSWORD}"
    "MESSAGE_SERVER_URL"    = "${var.MESSAGE_SERVER_URL}"
  }

  tags = local.amway_common_tags
}
