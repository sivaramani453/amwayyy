module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.25.0"

  user_enabled       = "false"
  name               = "${var.cluster_name}-rke-config"
  stage              = var.s3_stage
  namespace          = "amway"
  versioning_enabled = "false"

  tags = local.tags
}

