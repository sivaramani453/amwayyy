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

  s3_bucket          = "${data.terraform_remote_state.core.s3_lambda_bucket_name}"
  s3_key             = "volume_remover.zip"
  function_name      = "volume-remover"
  handler            = "volume_remover.handler"
  runtime            = "python3.7"
  timeout            = "30"
  custom_tags_common = "${var.custom_tags_common}"

  # Network config (sec group still be created, just ignore it)
  vpc_id  = ""
  subnets = []

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.every_day.arn}"

  env_vars = {
    Terraform = "True"
  }
}
