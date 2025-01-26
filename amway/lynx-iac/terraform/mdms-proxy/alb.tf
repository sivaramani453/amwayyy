module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  load_balancer_name        = "${var.service}"
  load_balancer_is_internal = "true"
  security_groups           = ["${module.mdms_proxy_ec2_sg.this_security_group_id}"]

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

  tags = "${local.amway_common_tags}"
}

resource "aws_lb_target_group_attachment" "target-mdms-proxy" {
  target_group_arn = "${module.alb.target_group_arns[0]}"
  target_id        = "${module.mdms_proxy_server_instance.id[0]}"
  port             = 1235
}
