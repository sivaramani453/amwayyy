locals {
  health_check_prerender_qa = {
    interval            = 10
    port                = "traffic-port"
    protocol            = "TCP"
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }
}

resource "aws_lb" "prerender_int_lb" {
  name               = "eks-prerender-qa-int-lb"
  internal           = true
  load_balancer_type = "network"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  subnets                    = data.terraform_remote_state.eks-core.outputs.private_subnets
  enable_deletion_protection = false
  idle_timeout               = 120

  tags = {
    Terraform = "true"
  }
}

resource "aws_lb_target_group" "prerender_tg" {
  name                 = "eks-prerender-qa-tg"
  port                 = "31282"
  protocol             = "TCP"
  vpc_id               = data.terraform_remote_state.eks-core.outputs.vpc_id
  target_type          = "instance"
  deregistration_delay = 300
  slow_start           = 0

  dynamic "health_check" {
    for_each = [local.health_check_prerender_qa]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      enabled             = lookup(health_check.value, "enabled", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      interval            = lookup(health_check.value, "interval", null)
      matcher             = lookup(health_check.value, "matcher", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      protocol            = lookup(health_check.value, "protocol", null)
      timeout             = lookup(health_check.value, "timeout", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
    }
  }

  tags = {
    Terraform = "true"
  }
}

resource "aws_lb_listener" "prerender_int_lb_listner" {
  load_balancer_arn = aws_lb.prerender_int_lb.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:eu-central-1:728244295542:certificate/240f53e3-94fb-44ec-b30c-a356f49e5668"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prerender_tg.arn
  }
}

resource "aws_route53_record" "prerender_qa" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "prerender-qa.mspreprod.eia.amway.net"
  type    = "A"

  alias {
    name                   = aws_lb.prerender_int_lb.dns_name
    zone_id                = aws_lb.prerender_int_lb.zone_id
    evaluate_target_health = "false"
  }
}

