data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "core-eks" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "eks-v2/core.tfstate"
    region = "eu-central-1"
  }
}

module "lambda_function" {
  source = "../../modules/lambda_with_efs"

  s3_bucket     = "${data.terraform_remote_state.core.s3_lambda_bucket_name}"
  s3_key        = "efs_backup_cleanup.zip"
  function_name = "EFSBackupCleanup${upper(terraform.workspace)}"
  handler       = "efs_backup_cleanup.lambda_handler"
  runtime       = "python3.8"
  timeout       = "900"

  vpc_id  = "${data.terraform_remote_state.core-eks.vpc_id}"
  subnets = ["${data.terraform_remote_state.core-eks.infra_subnets}"]

  efs_ap_arn     = "${var.efs_ap_arn}"
  efs_mount_path = "${var.efs_mount_path}"

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.efs_every_month.arn}"

  env_vars = {
    EFS_MOUNT_PATH = "${var.efs_mount_path}"
    RETENTION_DAYS = "${var.retention_days}"
  }
}
