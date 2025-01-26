#module "s3_bucket" {
#  source  = "cloudposse/s3-bucket/aws"
#  version = "0.3.0"
#
#  user_enabled       = "false"
#  name               = "microservice-${terraform.workspace}"
#  region             = "eu-central-1"
#  stage              = "dev"
#  namespace          = "amway"
#  versioning_enabled = "false"

#  tags {
#    Terraform          = "true"
#    ApplicationID      = "APP3150571"
#    DataClassification = "internal"
#  }
#}

# S3 buckets
resource "aws_s3_bucket" "front" {
  bucket = "amway-microservice-static-prod"
#  acl    = "public-read"
  acl = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags {
    Terraform          = "true"
    ApplicationID      = "APP3150571"
    DataClassification = "internal"
  }
}

#  count  = "${terraform.workspace == "marketplace-auth-eks-pubdv" ? 0 : 1}"

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = "${aws_s3_bucket.front.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "SUBSCRIPTIONEVPOLICY",
  "Statement": [
    {
      "Sid": "DeploySubscriptionDev",
      "Effect": "Allow",
      "Principal": {"AWS": ["${var.AWS_user_arn}", "${var.AWS_runner_arn}"]},
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
#    {
#      "Sid": "PublicRead",
#      "Effect": "Allow",
#      "Principal": "*",
#      "Action": [
#          "s3:GetObject",
#          "s3:GetObjectVersion"
#      ],
#      "Resource": [
#          "${aws_s3_bucket.b.arn}/*",
#          "${aws_s3_bucket.b.arn}"]
#    }

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  default_root_object = "index.html"
  aliases = ["${var.alb_domain}"]
# S3 bucket origin
  origin {
    domain_name = "${aws_s3_bucket.front.bucket_regional_domain_name}"
    origin_id   = "S3-${aws_s3_bucket.front.bucket}"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.front.bucket}"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
#    viewer_protocol_policy = "allow-all"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
/*# Cache behavior with precedence 0 - S3
  ordered_cache_behavior {
    path_pattern     = "*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${aws_s3_bucket.front.bucket}"
    forwarded_values {
      query_string = true
      query_string_cache_keys = []
      headers      = ["Some"]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
*/
  
############
  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Terraform = "True"
    Evironment = "PROD"
    DataClassification = "Internal"
    ApplicationID = "APP3150571"

  }
  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:645993801158:certificate/c44713b2-69e7-484b-95d8-7c9d50cce2c6"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

resource "aws_route53_record" "cloudfront_record" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.alb_domain}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
