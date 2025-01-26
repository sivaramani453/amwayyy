module "alb_security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "2.9.0"
  name                = "EPAM-${var.ec2_name}-alb"
  description         = "Security group for nexus alb with HTTP and HTTPS ports open"
  vpc_id              = "${data.terraform_remote_state.core.vpc.dev.id}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  tags                = "${local.tags}"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  load_balancer_name        = "${var.ec2_name}"
  load_balancer_is_internal = "true"
  security_groups           = ["${module.alb_security_group.this_security_group_id}"]

  subnets = [
    "${data.terraform_remote_state.core.subnet.core_a.id}",
    "${data.terraform_remote_state.core.subnet.core_b.id}",
  ]

  vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"

  logging_enabled = "false"

  listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  https_listeners             = "${local.https_listeners}"
  https_listeners_count       = "${local.https_listeners_count}"

  target_groups          = "${local.target_groups}"
  target_groups_count    = "${local.target_groups_count}"
  target_groups_defaults = "${local.target_groups_defaults}"

  tags = "${local.tags}"
}

# Add redirect from 80 to 443
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = "${module.alb.load_balancer_id}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}

# Forward 443 to 8081
resource "aws_lb_target_group_attachment" "alb_registered_targets" {
  target_group_arn = "${module.alb.target_group_arns[0]}"
  target_id        = "${aws_instance.nexus_ec2_instance.id}"
  port             = 8081
}

# Forward 8083 to 8083
resource "aws_lb_target_group_attachment" "alb_registered_targets_docker" {
  target_group_arn = "${module.alb.target_group_arns[1]}"
  target_id        = "${aws_instance.nexus_ec2_instance.id}"
  port             = 8083
}

# Create route53 record with alias to ALB
resource "aws_route53_record" "common" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "nexus.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.alb.dns_name}"
    zone_id                = "${module.alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}
