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
  name                       = "eks-prerender-qa-int-lb"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = ["${data.terraform_remote_state.eks-core.private_subnets}"]
  enable_deletion_protection = false
  idle_timeout               = 120

  tags {
    Terraform = "true"
  }
}

resource "aws_lb_target_group" "prerender_tg" {
  name                 = "eks-prerender-qa-tg"
  port                 = "31282"
  protocol             = "TCP"
  vpc_id               = "${data.terraform_remote_state.eks-core.vpc_id}"
  target_type          = "instance"
  deregistration_delay = 300
  slow_start           = 0

  health_check = ["${local.health_check_prerender_qa}"]

  tags {
    Terraform = "true"
  }
}

resource "aws_lb_listener" "prerender_int_lb_listner" {
  load_balancer_arn = "${aws_lb.prerender_int_lb.arn}"
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:eu-central-1:860702706577:certificate/3bce1dc0-e691-4521-9fca-4f5430776282"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.prerender_tg.arn}"
  }
}

resource "aws_route53_record" "prerender_qa" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "prerender-qa.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${aws_lb.prerender_int_lb.dns_name}"
    zone_id                = "${aws_lb.prerender_int_lb.zone_id}"
    evaluate_target_health = "false"
  }
}
