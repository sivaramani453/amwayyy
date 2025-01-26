module "pl_nodes_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 3.0"

  logging_enabled            = false
  load_balancer_name         = "${terraform.workspace}"
  load_balancer_is_internal  = true
  subnets                    = "${local.core_subnet_ids}"
  enable_deletion_protection = false
  security_groups            = ["${module.alb_nodes_sg.this_security_group_id}"]
  idle_timeout               = 120
  vpc_id                     = "${data.terraform_remote_state.core.vpc.dev.id}"

  https_listeners       = "${local.pl_https_listeners}"
  https_listeners_count = "${local.pl_https_listeners_count}"
  target_groups         = "${local.pl_target_groups}"
  target_groups_count   = "${local.pl_target_groups_count}"

  tags = "${local.custom_tags_common}"
}

resource "aws_lb_target_group_attachment" "pl_nodes" {
  count            = "${var.ec2_pl_nodes_count}"
  target_group_arn = "${module.pl_nodes_alb.target_group_arns[0]}"
  target_id        = "${element(aws_instance.pl_nodes.*.id, count.index)}"
}
