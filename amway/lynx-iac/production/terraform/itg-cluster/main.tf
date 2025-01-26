data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "s3_bucket" {
  source       = "cloudposse/s3-bucket/aws"
  version      = "0.3.0"
  user_enabled = "true"
  name         = "itg-cluster-rke-config"
  region       = "eu-central-1"
  stage        = "prod"
  namespace    = "amway"

  tags = {
    Terraform   = "true"
    Environment = "prod"
    Service     = "itg-cluster"
  }
}

resource "aws_route53_record" "cluster-api" {
  zone_id = "${data.terraform_remote_state.core.route53_zone_id}"
  name    = "itg-cluster.ms.eia.amway.net"
  type    = "A"
  ttl     = "300"
  records = ["10.253.127.1"]
}
