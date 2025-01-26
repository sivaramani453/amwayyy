locals {
  enable_waf = var.waf_enabled ? 1 : 0
}

resource "aws_wafv2_ip_set" "amway_vpns" {
  count              = local.enable_waf
  provider           = aws.edge_region
  name               = "amway_vpns_${terraform.workspace}"
  description        = "Amway VPN gateways"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["167.23.0.0/16", "195.133.241.32/32", "185.128.158.41/32", "61.95.172.227/32", "35.157.159.179/32", "18.198.28.84/32", "3.126.177.142/32", "18.198.168.1/32", "52.58.138.65/32", "18.159.95.224/32", "13.224.132.0/24"]

  tags = {
    Terraform = "True"
    Evironment = "DEV"
    DataClassification = "Internal"
    ApplicationID = "APP3150571"
  }
}

resource "aws_wafv2_web_acl" "firewall" {
  count       = local.enable_waf
  provider    = aws.edge_region
  name        = "cf-webacl-${terraform.workspace}"
  description = "WAF firewall rule for FQA/UAT CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.amway_vpns[0].arn
      }
    }
    
    action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "cf-firewall-rule1-metrics-${terraform.workspace}"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Terraform = "True"
    Evironment = "DEV"
    DataClassification = "Internal"
    ApplicationID = "APP3150571"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cf-firewall-metrics-${terraform.workspace}"
    sampled_requests_enabled   = false
  }
}
