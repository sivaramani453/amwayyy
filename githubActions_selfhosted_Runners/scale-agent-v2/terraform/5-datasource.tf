data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "s3_bucket" {
  bucket = "github-actions-selfhosted-runners-s3"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnet" "subnet_id1" {
  id = var.subnet_id1
}
data "aws_subnet" "subnet_id2" {
  id = var.subnet_id2
}