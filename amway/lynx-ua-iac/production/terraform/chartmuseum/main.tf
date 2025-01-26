data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "rancher-cluster" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "rancher-server.tfstate"
    region = "eu-central-1"
  }
}

module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.3.0"

  user_enabled       = "true"
  name               = "chartmuseum-bucket"
  region             = "eu-central-1"
  stage              = "prod"
  namespace          = "amway"
  versioning_enabled = "false"

  tags = "${local.tags}"
}

resource "aws_route53_record" "chartmuseum" {
  zone_id = "${data.terraform_remote_state.core.route53_zone_id}"
  name    = "chartmuseum.ms.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${data.terraform_remote_state.rancher-cluster.alb_dns}"
    zone_id                = "${data.terraform_remote_state.rancher-cluster.alb_zone_id}"
    evaluate_target_health = true
  }
}
