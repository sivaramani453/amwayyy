module "be_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 3.0"

  logging_enabled            = false
  load_balancer_name         = "${terraform.workspace}-backend"
  load_balancer_is_internal  = true
  subnets                    = "${local.core_subnet_ids}"
  enable_deletion_protection = false
  security_groups            = ["${module.alb_nodes_sg.this_security_group_id}"]
  idle_timeout               = 120
  vpc_id                     = "${data.terraform_remote_state.core.vpc.dev.id}"

  https_listeners       = "${local.be_https_listeners}"
  https_listeners_count = "${local.be_https_listeners_count}"
  target_groups         = "${local.be_target_groups}"
  target_groups_count   = "${local.be_target_groups_count}"
}

resource "aws_lb_target_group_attachment" "backend" {
  count            = "${var.ec2_be_instance_count}"
  target_group_arn = "${module.be_alb.target_group_arns[0]}"
  target_id        = "${element(aws_instance.be_nodes.*.id, count.index)}"
}

module "fe_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 3.0"

  logging_enabled            = false
  load_balancer_name         = "${terraform.workspace}-frontend"
  load_balancer_is_internal  = true
  subnets                    = "${local.core_subnet_ids}"
  enable_deletion_protection = false
  security_groups            = ["${module.alb_nodes_sg.this_security_group_id}"]
  idle_timeout               = 120
  vpc_id                     = "${data.terraform_remote_state.core.vpc.dev.id}"

  https_listeners          = "${local.fe_https_listeners}"
  https_listeners_count    = "${local.fe_https_listeners_count}"
  http_tcp_listeners       = "${local.fe_storybook_http_tcp_listeners}"
  http_tcp_listeners_count = "${local.fe_storybook_http_tcp_listeners_count}"
  target_groups            = "${local.fe_target_groups}"
  target_groups_count      = "${local.fe_target_groups_count}"
}

resource "aws_lb_target_group_attachment" "frontend" {
  count            = "${var.ec2_fe_instance_count}"
  target_group_arn = "${module.fe_alb.target_group_arns[0]}"
  target_id        = "${element(aws_instance.fe_nodes.*.id, count.index)}"
}

resource "aws_lb_target_group_attachment" "frontend_sb" {
  count            = "${var.ec2_fe_instance_count}"
  target_group_arn = "${module.fe_alb.target_group_arns[1]}"
  target_id        = "${element(aws_instance.fe_nodes.*.id, count.index)}"
}
