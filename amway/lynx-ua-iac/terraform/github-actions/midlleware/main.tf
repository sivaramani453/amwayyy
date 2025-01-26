locals {
  enabled {
    default = false
    test    = true
  }

  git_token {
    default = "${var.github_token}"
  }

  git_secret {
    default = "${var.github_webhook_secret}"
  }

  skype_chat_id {
    default = "${var.skype_chat_id}"
  }

  skype_secret {
    default = "${var.skype_secret}"
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
  source = "../../modules/lambda"

  function_name      = "gh-middleware-${terraform.workspace}-v2"
  s3_bucket          = "${data.terraform_remote_state.core.s3_lambda_bucket_name}"
  s3_key             = "gh-middleware-v2.zip"
  handler            = "gh-middleware-v2"
  runtime            = "go1.x"
  timeout            = "30"
  custom_tags_common = "${var.custom_tags_common}"

  # Network config
  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]

  statement_id = "AllowAPIGatewayInvoke"
  principal    = "apigateway.amazonaws.com"
  arn          = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/"

  env_vars {
    ENABLED       = "${lookup(local.enabled, terraform.workspace, local.enabled["default"])}"
    GIT_TOKEN     = "${lookup(local.git_token, terraform.workspace, local.git_token["default"])}"
    GIT_SECRET    = "${lookup(local.git_secret, terraform.workspace, local.git_secret["default"])}"
    SKYPE_CHAT_ID = "${lookup(local.skype_chat_id, terraform.workspace, local.skype_chat_id["default"])}"
    SKYPE_SECRET  = "${lookup(local.skype_secret, terraform.workspace, local.skype_secret["default"])}"
  }
}
