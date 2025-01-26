module "nexus_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.10.0"

  name                        = "Nexus-Load-Balancer"
  internal                    = "true"
  security_groups             = list(module.nexus_alb_sg.this_security_group_id)
  subnets                     = local.alb_subnets
  vpc_id                      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id
  listener_ssl_policy_default = local.alb_listener_ssl_policy

  tags              = local.amway_common_tags
  lb_tags           = local.amway_common_tags
  target_group_tags = local.amway_common_tags

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  target_groups   = local.alb_target_groups
  https_listeners = local.alb_https_listeners
}

resource "aws_route53_record" "common" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  # URL must be a subdomain for a zone, which is hybris.eu.eia.amway.net in this case
  name = "nexus.hybris.eu.eia.amway.net"
  type = "A"

  alias {
    name                   = module.nexus_alb.this_lb_dns_name
    zone_id                = module.nexus_alb.this_lb_zone_id
    evaluate_target_health = true
  }
}

# Haven't found a way to use module to register hosts in target groups, therefore using raw resources
resource "aws_lb_target_group_attachment" "nexus_ui_backend" {
  count            = length(local.instance_subnets)
  target_group_arn = module.nexus_alb.target_group_arns[0]
  target_id        = element(module.nexus_ec2_instance.id, count.index)
}

resource "aws_lb_target_group_attachment" "nexus_docker_backend" {
  count            = length(local.instance_subnets)
  target_group_arn = module.nexus_alb.target_group_arns[1]
  target_id        = element(module.nexus_ec2_instance.id, count.index)
}