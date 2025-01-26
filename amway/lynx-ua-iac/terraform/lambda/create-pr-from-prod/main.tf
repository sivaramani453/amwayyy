locals {
  code_repo {
    eu = "${var.eu_code_repo}"
    ru = "${var.ru_code_repo}"
  }

  config_repo {
    eu = "${var.eu_config_repo}"
    ru = "${var.ru_config_repo}"
  }

  branches = {
    eu = "${var.git_eu_branches}"
    ru = "${var.git_ru_branches}"
  }

  teams_channel = {
    eu = "${var.teams_eu_channel}"
    ru = "${var.teams_ru_channel}"
  }
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "lambda_function" {
  depends_on = ["${aws_ssm_parameter.commit_sha_lynx.arn}",
    "${aws_ssm_parameter.commit_sha_lynx_conf.arn}",
  ]

  source = "../../modules/lambda"

  function_name = "create-pr-from-prod-${terraform.workspace}"
  s3_bucket     = "${data.terraform_remote_state.core.s3_lambda_bucket_name}"
  s3_key        = "create-prs.zip"

  handler            = "main.lambda_handler"
  runtime            = "python3.7"
  timeout            = "120"
  custom_tags_common = "${var.custom_tags_common}"

  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.trigger_check.arn}"

  env_vars {
    REF                 = "prod"
    ORG                 = "AmwayEIA"
    GITHUB_API_TOKEN    = "${var.git_token}"
    CODE_REPO           = "${local.code_repo[terraform.workspace]}"
    CONFIG_REPO         = "${local.config_repo[terraform.workspace]}"
    PARAMETER_LYNX      = "${aws_ssm_parameter.commit_sha_lynx.name}"
    PARAMETER_LYNX_CONF = "${aws_ssm_parameter.commit_sha_lynx_conf.name}"
    BRANCHES            = "${local.branches[terraform.workspace]}"
    TEAMS_CHANNEL       = "${local.teams_channel[terraform.workspace]}"
  }
}
