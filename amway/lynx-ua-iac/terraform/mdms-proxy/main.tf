data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "mdms_proxy_server_ami" {
  owners      = ["self", "amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["mdms_proxy*"]
  }
}

module "mdms_proxy_server_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 1.0"

  name           = "${terraform.workspace}-mdms-proxy-server"
  instance_count = "1"

  ami                    = "${data.aws_ami.mdms_proxy_server_ami.id}"
  ebs_optimized          = true
  instance_type          = "t3.medium"
  key_name               = "EPAM-SE"
  monitoring             = true
  vpc_security_group_ids = ["${module.mdms_proxy_ec2_sg.this_security_group_id}"]
  subnet_id              = "${data.terraform_remote_state.core.subnet.core_a.id}"

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = 20
      delete_on_termination = true
    },
  ]

  tags        = "${merge(local.amway_common_tags, local.amway_ec2_specific_tags)}"
  volume_tags = "${merge(map("ServiceType", "mdms-api-proxy" ), local.amway_common_tags, local.amway_ebs_specific_tags)}"
}

resource "aws_route53_record" "mdms_ts3_proxy_server" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "api-ts3-proxy.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.alb.dns_name}"
    zone_id                = "${module.alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "mdms_qa_proxy_server" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "api-qa-proxy.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.alb.dns_name}"
    zone_id                = "${module.alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "mdms_qa3_proxy_server" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "api-qa3-proxy.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.alb.dns_name}"
    zone_id                = "${module.alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}
