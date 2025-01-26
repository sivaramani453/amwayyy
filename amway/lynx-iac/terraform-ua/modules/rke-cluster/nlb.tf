module "load_balancer" {
  source = "../aws-nlb"

  load_balancer_name        = "${var.cluster_name}-kube-api-lb"
  load_balancer_is_internal = true

  vpc_id  = "${var.vpc_id}"
  subnets = "${var.subnets}"

  target_groups_count = 1
  tcp_listeners_count = 1
  tcp_listeners       = ["${local.listener}"]
  target_groups       = ["${local.target_group}"]

  tags = "${local.tags}"
}

resource "aws_lb_target_group_attachment" "master" {
  count            = "${var.masters}"
  target_group_arn = "${module.load_balancer.aws_lb_target_group_arn[0]}"
  target_id        = "${element(aws_instance.kube-masters.*.id, count.index)}"
}
