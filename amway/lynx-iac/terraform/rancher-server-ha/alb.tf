module "alb_security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "2.9.0"
  name                = "rancher-alb-sg"
  description         = "Security group for Rancher alb"
  vpc_id              = "${data.terraform_remote_state.core.vpc.dev.id}"
  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  tags                = "${local.tags}"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  load_balancer_name        = "rancher-alb"
  load_balancer_is_internal = "true"
  security_groups           = ["${module.alb_security_group.this_security_group_id}"]

  subnets = "${local.subnets}"
  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"

  logging_enabled = "false"

  listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  https_listeners             = "${local.https_listeners}"
  https_listeners_count       = 1

  target_groups          = ["${local.ingress_target_group_https}"]
  target_groups_count    = 1
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

resource "aws_alb_target_group_attachment" "internal-ingress-alb" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.alb.target_group_arns[0]}"
  target_id        = "${element(module.kubernetes-cluster.workers_private_ips, count.index)}"
}
