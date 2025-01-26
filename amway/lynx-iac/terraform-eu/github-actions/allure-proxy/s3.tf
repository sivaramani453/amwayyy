module "allure_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "amway-dev-eu-allure-reports"

  lifecycle_rule = local.allure_reports_configurations

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket = "amway-dev-eu-allure-reports"
  key    = "404.html"
  source = "${path.module}/files/404.html"
}

resource "aws_s3_bucket_policy" "allure_s3_policy" {
  bucket = module.allure_s3_bucket.this_s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AllowGetObjFromHybrisVPC"
    Statement = [
      {
        Sid       = "AllowS3GetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${module.allure_s3_bucket.this_s3_bucket_arn}/*",
        Condition = {
          StringLike = {
            "aws:UserAgent" : var.user_agent
          },
          IpAddress = {
            "aws:SourceIp" = [
              "18.198.28.84/32",
              "35.157.159.179/32",
              "3.126.177.142/32"
            ]
          }
        }
      },
    ]
  })
}
