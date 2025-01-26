module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.3.0"

  user_enabled       = "false"
  name               = "${var.s3_name}"
  region             = "eu-central-1"
  namespace          = "amway"
  stage              = "dev"
  versioning_enabled = "false"

  policy = "${data.template_file.bucket_policy.rendered}"
  tags   = "${local.tags}"
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket = "amway-dev-${var.s3_name}"
  key    = "404.html"
  source = "${path.module}/files/404.html"
}
