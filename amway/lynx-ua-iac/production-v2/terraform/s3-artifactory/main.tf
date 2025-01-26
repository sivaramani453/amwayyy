module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.3.0"

  user_enabled       = "false"
  name               = "artifactory-bucket"
  region             = "eu-central-1"
  stage              = "prod-ru"
  namespace          = "amway"
  versioning_enabled = "false"

  tags = {
    Terraform = "true"
    Service   = "artifactory-bucket"
  }
}
