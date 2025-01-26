module "instance_scheduler_sg_lb" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.ecs_service_name}-lb-sg"
  description = "Security group for the AWS Instance Scheduler Web Application"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

module "instance_scheduler_lb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name               = "${var.ecs_service_name}-backend"
  load_balancer_type = "application"
  internal           = true
  subnets            = local.core_subnet_ids
  security_groups    = [module.instance_scheduler_sg_lb.this_security_group_id]
  idle_timeout       = 120
  vpc_id             = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_302"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = local.lb_certificate_arn
      ssl_policy         = local.lb_ssl_policy
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name_prefix          = "inshui"
      backend_protocol     = "HTTP"
      backend_port         = lookup(local.container, "port")
      target_type          = "ip"
      slow_start           = 0
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 15
        path                = "/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  tags = local.amway_common_tags

  lb_tags = local.amway_common_tags

  target_group_tags = local.amway_common_tags
}

resource "aws_route53_record" "instance_scheduler_url" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "aws-instance-scheduler.${local.route53_zone_name}"
  type    = "A"

  alias {
    name                   = module.instance_scheduler_lb.this_lb_dns_name
    zone_id                = module.instance_scheduler_lb.this_lb_zone_id
    evaluate_target_health = true
  }
}
