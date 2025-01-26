# 'ru' and 'eu are names of tf workspaces'
locals {
  git_token = {
    eu = "${var.git_eu_token}"
    ru = "${var.git_ru_token}"
  }

  teams_secret = {
    eu = "${var.teams_eu_secret}"
    ru = "${var.teams_ru_secret}"
  }

  branches_list = {
    ru = ["dev-dev", "dev-rel", "support-dev", "support-rel", "dev-pref", "dev-rel-perf", "dev-rel-orderflow"]
    eu = ["dev-dev", "dev-rel", "support-dev", "support-rel"]
  }
}

# Network data required
data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "lambda" {
  source = "../../modules/lambda"

  s3_bucket          = "${data.terraform_remote_state.core.s3_lambda_bucket_name}"
  s3_key             = "pull-requests-queue.zip"
  function_name      = "PullRequestQueue${upper(terraform.workspace)}"
  handler            = "main.lambda_handler"
  runtime            = "python3.7"
  timeout            = "120"
  custom_tags_common = "${var.custom_tags_common}"

  # Network config (sec group still be created, just ignore it)
  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.every_few_minutes.arn}"

  env_vars = {
    REGION         = "${terraform.workspace}"
    GIT_TOKEN      = "${local.git_token[terraform.workspace]}"
    SKYPE_SECRET   = "${var.skype_secret}"
    TEAMS_SECRET   = "${local.teams_secret[terraform.workspace]}"
    DYNAMODB_TABLE = "${var.dynamodb_table}"
  }
}
