terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      ApplicationID      = "APP3001178"
      Contact            = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com"
      Project            = "CICD"
      DataClassification = "Internal"
      Environment        = "DEV"
    }
  }
}


resource "aws_s3_bucket" "terraform-state" {
  bucket = "jpn-automation-dev-tfstate"
}

# resource "aws_s3_bucket_acl" "terraform-state-acls" {
#   bucket = aws_s3_bucket.terraform-state.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state-encryption" {
  bucket = aws_s3_bucket.terraform-state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform-state" {
  name           = "jpn-automation-dev-tfstate"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
