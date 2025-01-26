locals {
  amway_common_tags = {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }

  amway_data_tags = {
    DataClassification = "Internal"
  }
}

module "mysql_be_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.9.0"

  bucket = "amway-dev-eu-mysql-be"

  lifecycle_rule = [
    {
      id      = "dev-rel"
      enabled = true
      prefix  = "dev-rel/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "support-dev"
      enabled = true
      prefix  = "support-dev/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "support-rel"
      enabled = true
      prefix  = "support-rel/"

      expiration = {
        days = 30
      }
    },
  ]

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}
