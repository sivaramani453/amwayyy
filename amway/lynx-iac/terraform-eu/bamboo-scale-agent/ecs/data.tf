data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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
