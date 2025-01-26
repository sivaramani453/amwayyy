# Network data required
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

  function_name      = "github-middleware-${terraform.workspace}"
  s3_bucket          = "${data.terraform_remote_state.core.s3_lambda_bucket_name}"
  s3_key             = "webhook-${terraform.workspace}.zip"
  handler            = "webhook-${terraform.workspace}"
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
    SKYPE_SECRET    = "${var.SKYPE_SECRET}"
    CHAT_ID         = "${var.CHAT_ID}"
    BAMBOO_URL      = "${var.BAMBOO_URL}"
    BAMBOO_USER     = "${var.BAMBOO_USER}"
    BAMBOO_PASSWORD = "${var.BAMBOO_PASSWORD}"
    SECRET          = "${var.SECRET}"
    TOKEN           = "${var.TOKEN}"
  }
}
