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
  s3_key             = "docker_db_snapshot_cleanup.zip"
  function_name      = "DockerDBSnapshotCleanup"
  handler            = "docker_db_snapshot_cleanup.lambda_handler"
  runtime            = "python3.7"
  timeout            = "30"
  custom_tags_common = "${var.custom_tags_common}"

  # Network config (sec group still be created, just ignore it)
  vpc_id  = ""
  subnets = []

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.every_fifth_day.arn}"

  env_vars = {
    AWS_REGION_NAME = "eu-central-1"
  }
}
