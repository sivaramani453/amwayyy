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

  name        = "gh-middleware-${terraform.workspace}-lambda-sg"
  description = "Security group for the Middleware Lambda in VPC"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

module "lambda_function_s3" {
  source = "terraform-aws-modules/lambda/aws"

  version = "2.1.0"

  function_name                           = "gh-middleware-${terraform.workspace}-v2"
  description                             = "The Middleware to handle labeled actions on pull requests"
  handler                                 = "gh-middleware-v2"
  runtime                                 = "go1.x"
  timeout                                 = "30"
  vpc_subnet_ids                          = local.lambda_subnet_ids
  vpc_security_group_ids                  = [module.lambda_sg.this_security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.terraform_remote_state.core.outputs.s3_lambda_bucket_name
    key    = "gh-middleware-v2.zip"
  }

  allowed_triggers = {
    AllowAPIGatewayInvoke = {
      principal  = "apigateway.amazonaws.com"
      source_arn = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/"
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
      actions   = ["ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces"],
      resources = ["*"]
    }
  }

  environment_variables = {
    ENABLED       = "${lookup(local.func_enabled, terraform.workspace, local.func_enabled["default"])}"
    GIT_TOKEN     = "${lookup(local.git_token, terraform.workspace, local.git_token["default"])}"
    GIT_SECRET    = "${lookup(local.git_secret, terraform.workspace, local.git_secret["default"])}"
    SKYPE_CHAT_ID = "${lookup(local.skype_chat_id, terraform.workspace, local.skype_chat_id["default"])}"
    SKYPE_SECRET  = "${lookup(local.skype_secret, terraform.workspace, local.skype_secret["default"])}"
  }

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_log_subscription_filter" "stream_to_elk" {
  depends_on = [module.lambda_function_s3]

  name            = "GithubLynxMiddleware-lambda-stream"
  filter_pattern  = "[timestamp=*Z, severity, requestID, message]"
  log_group_name  = module.lambda_function_s3.lambda_cloudwatch_log_group_name
  destination_arn = data.aws_lambda_function.send_logs_to_elk.arn
}
