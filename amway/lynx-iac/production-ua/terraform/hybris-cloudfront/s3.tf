resource "aws_s3_bucket" "front" {
  bucket = "amway-cloudfront-${terraform.workspace}-static"
  acl = "private"

  tags = {
    Terraform          = "True"
    Evironment         = var.waf_enabled ? "DEV" : "PROD"
    ApplicationID      = "APP3150571"
    DataClassification = "internal"
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = "${aws_s3_bucket.front.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "HYBRISROBOTPOLICY",
  "Statement": [
    {
      "Sid": "DeployCloudfrontRobots",
      "Effect": "Allow",
      "Principal": {"AWS": ["${var.aws_user_arn}", "${var.aws_runner_arn}"]},
      "Action": [
        "s3:PutObject", 
        "s3:GetObject", 
        "s3:ListBucket", 
        "s3:DeleteObject"
      ],
      "Resource": ["${aws_s3_bucket.front.arn}/*", 
                   "${aws_s3_bucket.front.arn}"]
    },
    {
      "Sid": "CloudFrontAccess",
      "Effect": "Allow",
      "Principal": {"AWS": ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]},
      "Action": [
          "s3:GetObject",
          "s3:ListBucket"
      ],
      "Resource": [
          "${aws_s3_bucket.front.arn}/*",
          "${aws_s3_bucket.front.arn}"]
    }
  ]  
}
POLICY
}
