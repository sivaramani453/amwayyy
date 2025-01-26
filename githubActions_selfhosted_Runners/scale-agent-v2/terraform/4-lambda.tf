module "lambda_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "gh-scale-agent-v2-${terraform.workspace}-lambda-sg"
  description = "Security group for the GitHub Actions scale agent Lambda in VPC"
  vpc_id      = data.aws_vpc.vpc.id
  ingress_cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.common_tags
}

module "lambda_function_s3" {
  source = "terraform-aws-modules/lambda/aws"
  version = "7.12.0"

  function_name                           = "gh-scale-agent-${lower(terraform.workspace)}-v2"
  description                             = "GitHub Actions scale agent v2"
  handler                                 = "main.lambda_handler"
  runtime                                 = "python3.12"
  timeout                                 = "900"
  memory_size                             = "1024"
  #reserved_concurrent_executions          = "5"
  vpc_subnet_ids                          = [data.aws_subnet.subnet_id1.id, data.aws_subnet.subnet_id2.id]
  vpc_security_group_ids                  = [module.lambda_sg.security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.aws_s3_bucket.s3_bucket.id
    key    = "scale-agent-v2.zip"
  }

  allowed_triggers = {
    # AllowAPIGatewayInvoke = {
    #   principal  = "apigateway.amazonaws.com"
    #   source_arn = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/"
    # },
    AllowSQSInvoke = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.webhook_queue.arn
    }
  }

  attach_policies = true
  policies = [
    module.gh_scale_agent_ssm_access_policy.arn,
    module.gh_scale_agent_ec2_access_policy.arn,
    module.gh_scale_agent_iam_access_policy.arn,
    module.gh_scale_agent_sqs_access_policy.arn
  ]
  number_of_policies = 4

  # publish     = true
  # provisioned_concurrent_executions = 20

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

#   environment_variables = {
#     GIT_ORG   = lookup(var.git_org, terraform.workspace, local.git_org["default"])
#     GIT_REPO  = lookup(var.git_repo, terraform.workspace, local.git_repo["default"])
#     GIT_TOKEN = lookup(var.git_token, terraform.workspace, local.git_token["default"])
#     GIT_SECRET = lookup(var.git_secret, terraform.workspace, local.git_secret["default"])

#     TEAMS_WEBHOOK_URL = lookup(var.teams_webhook_url, terraform.workspace, local.teams_webhook_url["default"])

#     SPOT_MAXPRICE      = lookup(var.spot_maxprice, terraform.workspace, local.spot_maxprice["default"])
#     INSTANCE_REGION    = data.aws_region.current.name
#     INSTANCE_TYPE      = lookup(var.instance_type, terraform.workspace, local.instance_type["default"])
#     INSTANCE_ONDEMAND  = lookup(var.instance_ondemand, terraform.workspace, local.instance_ondemand["default"])
#     INSTANCE_AMI       = lookup(var.instance_ami, terraform.workspace, local.instance_ami["default"])
#     INSTANCE_DISK_SIZE = lookup(var.instance_disk_size, terraform.workspace, local.instance_disk_size["default"])
#     INSTANCE_SUBNET    = lookup(var.instance_subnet, terraform.workspace, local.instance_subnet["default"])
#     INSTANCE_KP        = lookup(var.instance_kp, terraform.workspace, local.instance_kp["default"])
#     INSTANCE_SG        = lookup(var.instance_sg, terraform.workspace, local.instance_sg["default"])
#     INSTANCE_PROFILE   = aws_iam_instance_profile.gh_scale_agent_instance_iam_profile.name
#     # DYNAMODB_REGION    = data.aws_region.current.name
#     # DYNAMODB_TABLE     = module.gh_scale_agent_dynamodb_table.dynamodb_table_id
#   }

  environment_variables = {
    GIT_ORG   = var.git_org
    GIT_REPO  = var.git_repo
    GIT_TOKEN = var.git_token
    GIT_SECRET = var.git_secret

    TEAMS_WEBHOOK_URL = var.teams_webhook_url

    SPOT_MAXPRICE      = var.spot_maxprice
    INSTANCE_REGION    = data.aws_region.current.name
    INSTANCE_TYPE      = var.instance_type
    INSTANCE_ONDEMAND  = var.instance_ondemand
    INSTANCE_AMI       = var.instance_ami
    INSTANCE_DISK_SIZE = var.instance_disk_size
    INSTANCE_SUBNET    = local.instance_subnet["default"]
    INSTANCE_KP        = var.instance_kp
    INSTANCE_SG        = var.instance_sg
    INSTANCE_PROFILE   = aws_iam_instance_profile.gh_scale_agent_instance_iam_profile.name
    # DYNAMODB_REGION    = data.aws_region.current.name
    # DYNAMODB_TABLE     = module.gh_scale_agent_dynamodb_table.dynamodb_table_id
  }


  tags = local.common_tags
}