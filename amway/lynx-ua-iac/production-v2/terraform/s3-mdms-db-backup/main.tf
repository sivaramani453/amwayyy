module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.3.0"

  user_enabled       = "false"
  name               = "mdms-db-backup"
  region             = "eu-central-1"
  stage              = "prod-ru"
  namespace          = "amway"
  versioning_enabled = "false"

  tags = {
    Terraform = "true"
    Service   = "mdms-db-backup-bucket"
  }
}
