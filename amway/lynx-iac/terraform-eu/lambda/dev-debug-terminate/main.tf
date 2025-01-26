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

  name        = "dev-debug-terminate-lambda-sg"
  description = "Security group for the Dev Debug terminate Lambda in VPC"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "run-dev-debug-terminate-every-day"
  description         = "Run dev-debug terminator every day at 19:15 UTC (21:15 CET)"
  schedule_expression = "cron(15 19 * * ? *)"

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.every_day.name
  arn  = module.lambda_function_s3.lambda_function_arn
}

module "lambda_function_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.1.0"

  function_name                           = "DevDebugTerminate"
  description                             = "Terminate old dev debug instance"
  handler                                 = "dev_debug_terminate.handler"
  runtime                                 = "python3.8"
  timeout                                 = "180"
  vpc_subnet_ids                          = local.lambda_subnet_ids
  vpc_security_group_ids                  = [module.lambda_sg.this_security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.terraform_remote_state.core.outputs.s3_lambda_bucket_name
    key    = "dev_debug_terminate.zip"
  }

  allowed_triggers = {
    AllowExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.every_day.arn
    }
  }

  attach_policies = true
  policies = [
    module.dev_debug_terminate_ec2_access_policy.arn,
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
      actions   = ["ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DescribeInstances"],
      resources = ["*"]
    }
  }

  environment_variables = {
    "RETENTION_PERIOD" = "5"
  }

  tags = local.amway_common_tags
}

module "dev_debug_terminate_ec2_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "DDTL-EC2"
  path        = "/"
  description = "Policy for the dev debug terminate to access ec2"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
               "ec2:TerminateInstances"
            ],
            "Resource": [
               "*"
            ],
            "Condition": {"StringLike": {"ec2:ResourceTag/Name": [
              "dev_ruv*",
              "dev_euv*",
              "dev_aiu*",
              "dev_plu*",
              "dev_inc*",
              "dev_deu*"
            ]}}
        }
    ]
}
EOF
}
