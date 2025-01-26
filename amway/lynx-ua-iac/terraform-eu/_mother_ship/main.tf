provider "aws" {
  region = "eu-central-1"
  alias  = "tfstate"
}

locals {
  amway_common_tags {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }

  amway_data_tags {
    DataClassification = "Internal"
  }
}

resource "aws_s3_bucket" "terraform-state" {
  provider = "aws.tfstate"
  bucket   = "dev-eu-amway-terraform-states"
  acl      = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule = [
    {
      id      = "mothership-s3-lifecycle-rule"
      enabled = true

      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_expiration = {
        days = "30"
      }
    },
  ]

  tags = "${merge(local.amway_common_tags, local.amway_data_tags, map("Name", "Terraform State Storage"))}"
}

resource "aws_dynamodb_table" "terraform-state-lock" {
  provider       = "aws.tfstate"
  name           = "amway-terraform-lock"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = "${merge(local.amway_common_tags, local.amway_data_tags, map("Name", "Terraform State Lock Table"))}"
}
