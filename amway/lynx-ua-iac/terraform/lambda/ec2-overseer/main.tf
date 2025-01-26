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
  s3_key             = "ec2_overseer.zip"
  function_name      = "EC2Overseer"
  handler            = "ec2_overseer.handler"
  runtime            = "python3.7"
  timeout            = "30"
  custom_tags_common = "${var.custom_tags_common}"

  # Network config (sec group still be created, just ignore it)
  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}", "${data.terraform_remote_state.core.subnet.core_c.id}"]

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.every_day.arn}"

  env_vars = "${map("RUN_LIMIT_SEC", var.RUN_LIMIT_SEC, "MESSAGE_CHAT_NAME", var.MESSAGE_CHAT_NAME, "MESSAGE_CHAT_PASSWORD", var.MESSAGE_CHAT_PASSWORD, "MESSAGE_SERVER_URL", var.MESSAGE_SERVER_URL)}"
}
