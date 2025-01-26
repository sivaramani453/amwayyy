module "mdms_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.10.0"

  name               = "mdms-proxy-alb"
  load_balancer_type = "application"
  internal           = true
  subnets            = local.core_subnet_ids
  security_groups    = [module.mdms_proxy_ec2_sg.this_security_group_id]
  idle_timeout       = 120
  vpc_id             = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  http_tcp_listeners = local.http_listeners
  https_listeners    = local.https_listeners
  target_groups      = local.target_groups

  tags              = local.amway_common_tags
  lb_tags           = local.amway_common_tags
  target_group_tags = local.amway_common_tags
}

resource "aws_route53_record" "mdms_ts3_proxy_server" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "api-ts3-proxy.hybris.eu.eia.amway.net"
  type    = "A"

  alias {
    name                   = module.mdms_alb.this_lb_dns_name
    zone_id                = module.mdms_alb.this_lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "mdms_ts3_proxy_server" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "mdms-ts3-proxy.hybris.eu.eia.amway.net"
  type    = "A"

  alias {
    name                   = module.mdms_alb.this_lb_dns_name
    zone_id                = module.mdms_alb.this_lb_zone_id
    evaluate_target_health = true
  }
}