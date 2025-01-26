module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.3.0"

  user_enabled       = "true"
  name               = "${var.cluster_name}-rke-config"
  region             = "${var.region}"
  stage              = "${var.s3_stage}"
  namespace          = "amway"
  versioning_enabled = "false"

  tags = "${local.tags}"
}
