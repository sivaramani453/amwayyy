data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "s3_bucket" {
  source       = "cloudposse/s3-bucket/aws"
  version      = "0.3.0"
  user_enabled = "true"
  name         = "itg-cluster-etcd-backup"
  region       = "eu-central-1"
  stage        = "test"
  namespace    = "amway"

  tags = {
    Terraform   = "true"
    Environment = "test"
    Service     = "itg-cluster"
  }
}

resource "aws_route53_record" "cluster-api" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "itg-cluster.${data.terraform_remote_state.core.route53.zone.name}"
  type    = "A"
  ttl     = "300"
  records = ["10.253.126.1"]
}

resource "aws_route53_record" "monitoring" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "itg-cluster-monitoring.${data.terraform_remote_state.core.route53.zone.name}"
  type    = "A"
  ttl     = "300"
  records = ["10.253.126.6", "10.253.126.7", "10.253.126.8"]
}
