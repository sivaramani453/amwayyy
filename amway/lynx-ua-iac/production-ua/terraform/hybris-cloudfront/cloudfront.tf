resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
}

resource "aws_cloudfront_function" "redirect_to_www" {
  name    = var.waf_enabled ? "RedirectToWWW" : "RedirectToWWW-${terraform.workspace}"
  runtime = "cloudfront-js-1.0"
  comment = "Redirect domain to WWW"
  publish = true
  code    = file("${path.module}/functions/redirect_to_www.js")
}

resource "aws_cloudfront_cache_policy" "cache_policy" {
  name        = "${terraform.workspace}-hybris-cache-policy"
  comment     = "Hybris CF Cache policy"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "whitelist"
      cookies {
        items = [ "JSESSIONID" ]
      }
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_origin_request_policy" "origin_request_policy" {
  name    = "${terraform.workspace}-hybris-origin-request-policy"
  comment = "Hybris CF Origin request policy"
  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["User-Agent","Accept-Language","Host","csrftoken","Referer"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_distribution" "hybris_cf_distribution" {
  enabled      = true
  aliases      = ["${var.hybris_domain}", "${var.hybris_domain_short}"]
  http_version = "http1.1"
  price_class  = "PriceClass_100"
  web_acl_id   = var.waf_enabled ? aws_wafv2_web_acl.firewall[0].arn : ""
   
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  logging_config {
    include_cookies = false
    bucket          = "amway-cloudfront-ru-logs.s3.amazonaws.com"

    prefix          = "${terraform.workspace}"
  }
  
  tags = {
    Terraform = "True"
    Evironment = var.waf_enabled ? "DEV" : "PROD"
    DataClassification = "Internal"
    ApplicationID = "APP3150571"
  }
  
  viewer_certificate {
     acm_certificate_arn            = "${var.certificate_arn}"
     cloudfront_default_certificate = false
     minimum_protocol_version       = "TLSv1.1_2016"
     ssl_support_method             = "sni-only"
  }

# Default origin
  origin {
    domain_name = "${var.hybris_alb}"
    origin_id   = "default-${terraform.workspace}"
    origin_path = ""
    
    custom_origin_config {
	  http_port              = 80
	  https_port             = 443
	  origin_protocol_policy = "https-only"
	  origin_ssl_protocols   = ["TLSv1.1","TLSv1.2"]
          origin_read_timeout      = 180
          origin_keepalive_timeout = 10
	}
    custom_header {
          name  = "X-Custom-Source-ID"   
          value = "${var.custom_header}"
        }
    custom_header {
          name  = "X-Custom-Prerender-Host"   
          value = "${var.prerender_host}"
        }
    custom_header {
          name  = "X-Custom-Hybris-Host"   
          value = "${var.hybris_domain}"
        }
  }

# Prerender origin
  origin {
    domain_name = "${var.prerender_host}"
    origin_id   = "prerender-${terraform.workspace}"
    origin_path = ""

    custom_origin_config {
	  http_port              = 80
	  https_port             = 443
	  origin_protocol_policy = "https-only"
	  origin_ssl_protocols   = ["TLSv1.1","TLSv1.2"]
	  origin_read_timeout      = 180
	  origin_keepalive_timeout = 10
	}
  }
  
# S3 bucket origin
  origin {
    domain_name = "${aws_s3_bucket.front.bucket_regional_domain_name}"
    origin_id   = "S3-${aws_s3_bucket.front.bucket}"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "default-${terraform.workspace}"
    cache_policy_id          = aws_cloudfront_cache_policy.cache_policy.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_request_policy.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
#    min_ttl                = 0
#    default_ttl            = 86400
#    max_ttl                = 31536000
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect_to_www.arn
    }
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.origin_request_lambda.qualified_arn
      include_body = false
    }
    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = aws_lambda_function.origin_response_lambda.qualified_arn
      include_body = false
    }
  }
  
  ordered_cache_behavior {
    path_pattern     = "robots.txt"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.front.bucket}"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  depends_on = [
    aws_lambda_function.origin_request_lambda,
    aws_lambda_function.origin_response_lambda
  ]
}
