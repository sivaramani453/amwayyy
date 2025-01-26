module "lambda_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${terraform.workspace}-lambda-sg"
  description = "Security group for the ElasticSearchCurator Lambda in VPC"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "every-day-clean-${terraform.workspace}-logs"
  description         = "Clean old docs in the Elasticsearch cluster every day"
  schedule_expression = "rate(1 day)"

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_event_target" "every_day" {
  rule = aws_cloudwatch_event_rule.every_day.name
  arn  = module.lambda_function_s3.this_lambda_function_arn
}

module "lambda_function_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "1.35.0"

  function_name                           = "ElasticSearchCurator"
  description                             = "Clean old logs in the Elsaticsearch cluster"
  handler                                 = "clean_docs.lambda_handler"
  runtime                                 = "python3.7"
  timeout                                 = "120"
  vpc_subnet_ids                          = local.lambda_subnet_ids
  vpc_security_group_ids                  = [module.lambda_sg.this_security_group_id]
  cloudwatch_logs_retention_in_days       = 7
  create_current_version_allowed_triggers = false

  create_package = false
  s3_existing_package = {
    bucket = data.terraform_remote_state.core.outputs.s3_lambda_bucket_name
    key    = "curator.zip"
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
    elasticsearch_access = {
      effect    = "Allow",
      actions   = ["es:ESHttpPost", "es:ESHttpGet", "es:ESHttpPut", "es:ESHttpDelete"],
      resources = [aws_elasticsearch_domain.elasticsearch_cluster.arn]
    },
    ec2_access = {
      effect    = "Allow",
      actions   = ["ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces"],
      resources = ["*"]
    }
  }

  environment_variables = {
    HOST       = aws_elasticsearch_domain.elasticsearch_cluster.endpoint
    REGION     = data.aws_region.current.name
    RET_PERIOD = "7"
  }

  tags = local.amway_common_tags

}
