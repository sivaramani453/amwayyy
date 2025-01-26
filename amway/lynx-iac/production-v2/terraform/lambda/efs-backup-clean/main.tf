data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-ru-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  address_validation_subnet_ids = [
    "${data.terraform_remote_state.core.frankfurt.subnet.address_validation_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.address_validation_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.address_validation_c.id}",
  ]
}

module "lambda_function" {
  source = "../../modules/lambda_with_efs"

  s3_bucket     = "${data.terraform_remote_state.core.s3_lambda_bucket_name}"
  s3_key        = "efs_backup_cleanup.zip"
  function_name = "EFSBackupCleanup${upper(terraform.workspace)}"
  handler       = "efs_backup_cleanup.lambda_handler"
  runtime       = "python3.8"
  timeout       = "900"

  vpc_id  = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  subnets = "${local.address_validation_subnet_ids}"

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
