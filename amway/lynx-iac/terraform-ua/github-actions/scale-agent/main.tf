data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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

  s3_bucket     = "${data.terraform_remote_state.core.s3_lambda_bucket_name}"
  s3_key        = "scale-agent.zip"
  function_name = "scale-agent-${lower(terraform.workspace)}"
  handler       = "main.lambda_handler"
  runtime       = "python3.7"
  timeout       = "120"

  # Network config (sec group still be created, just ignore it)
  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.every_few_minutes.arn}"

  env_vars {
    GIT_ORG   = "${lookup(local.git_org, terraform.workspace, local.git_org["default"])}"
    GIT_REPO  = "${lookup(local.git_repo, terraform.workspace, local.git_repo["default"])}"
    GIT_TOKEN = "${lookup(local.git_token, terraform.workspace, local.git_token["default"])}"

    INSTANCE_REGION    = "${data.aws_region.current.name}"
    INSTANCE_TYPE      = "${lookup(local.instance_type, terraform.workspace, local.instance_type["default"])}"
    INSTANCE_AMI       = "${lookup(local.instance_ami, terraform.workspace, local.instance_ami["default"])}"
    INSTANCE_DISK_SIZE = "${lookup(local.instance_disk_size, terraform.workspace, local.instance_disk_size["default"])}"
    INSTANCE_SUBNET    = "${lookup(local.instance_subnet, terraform.workspace, local.instance_subnet["default"])}"
    INSTANCE_KP        = "${lookup(local.instance_kp, terraform.workspace, local.instance_kp["default"])}"
    INSTANCE_SG        = "${lookup(local.instance_sg, terraform.workspace, local.instance_sg["default"])}"
    INSTANCE_PROFILE   = "${aws_iam_instance_profile.ga-machine-profile.name}"
    DYNAMODB_REGION    = "${data.aws_region.current.name}"
    DYNAMODB_TABLE     = "${aws_dynamodb_table.table.name}"

    SKYPE_URL    = "${local.skype_url}"
    SKYPE_CHAN   = "${local.skype_chan}"
    SKYPE_SECRET = "${local.skype_secret}"
  }
}
