provider "aws" {
  region = "eu-central-1"
  alias  = "tfstate"
}

resource "aws_s3_bucket" "terraform-state" {
  provider = "aws.tfstate"
  bucket   = "amway-terraform-states"
  acl      = "private"

  tags {
    Name = "Terraform State Storage"
  }
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

  tags {
    Name = "Terraform State Lock Table"
  }
}
