# module "lambda_sqs_sg" {

#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 3.0"

#   name        = "gh-scale-agent-v2-${terraform.workspace}-lambda-sg"
#   description = "Security group for the GitHub Actions scale agent Lambda in VPC"
#   vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

#   ingress_cidr_blocks = local.vpn_subnet_cidrs
#   ingress_rules       = ["all-all"]

#   egress_rules = ["all-all"]

#   tags = local.amway_common_tags
# }

module "lambda_sqs_function_s3" {
  source = "terraform-aws-modules/lambda/aws"
  version = "7.12.0"

  function_name                           = "gh-scale-agent-sqs-${lower(terraform.workspace)}-v2"
  description                             = "GitHub Actions scale agent v2"
  handler                                 = "main.queue_message"
  runtime                                 = "python3.12"
  timeout                                 = "900"
  memory_size                             = "1024"
#   reserved_concurrent_executions          = "20"
  vpc_subnet_ids                          = [data.aws_subnet.subnet_id1.id, data.aws_subnet.subnet_id2.id]
  vpc_security_group_ids                  = [module.lambda_sg.security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.aws_s3_bucket.s3_bucket.id
    key    = "scale-agent-v2.zip"
  }

  # allowed_triggers = {
  #   # AllowAPIGatewayInvoke = {
  #   #   principal  = "apigateway.amazonaws.com"
  #   #   source_arn = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/"
  #   # },
  #   AllowSQSInvike = {
  #     principal  = "sqs.amazonaws.com"
  #     source_arn = "${aws_sqs_queue.webhook_queue.arn}"
  #   }
  # }

  attach_policies = true
  policies = [
    module.gh_scale_agent_ssm_sqs_access_policy.arn,
    module.gh_scale_agent_iam_access_policy.arn,
    module.gh_scale_agent_sqs_publish_policy.arn,
    module.gh_scale_agent_ec2_access_policy.arn
  ]
  number_of_policies = 4

  attach_policy_statements = true

  create_lambda_function_url = true
  authorization_type         = "NONE"

  # publish     = true
  # provisioned_concurrent_executions = 20

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
    },
    sqs_access = {
      effect    = "Allow",
      actions   = ["sqs:*"],
      resources = ["*"]
    }
  }

  
#   {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "StatementId": "FunctionURLAllowPublicAccess",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": "lambda:InvokeFunctionUrl",
#       "Resource": module.lambda_sqs_function_s3.arn,
#       "Condition": {
#         "StringEquals": {
#           "lambda:FunctionUrlAuthType": "NONE"
#         }
#       }
#     }
#   ]
#   }

  environment_variables = {
    GIT_SECRET = var.git_secret
    TARGET_SQS_NAME = "gh-scale-agent-v2-${terraform.workspace}-queue"
    # ^^^^^^ Same as defined in sqs.tf!!
    TEAMS_WEBHOOK_URL = var.teams_webhook_url
  }

  #destination_config {
    destination_on_success  = aws_sqs_queue.webhook_queue.arn
    #}
  #}

  tags = local.common_tags
  
}