resource "aws_lb" "vault_cluster_lb" {
  name                       = "${var.vault_cluster_name}"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.vault_cluster_sg_lb.id}"]
  subnets                    = ["${data.terraform_remote_state.core.frankfurt_subnet_ec2_a_id}", "${data.terraform_remote_state.core.frankfurt_subnet_ec2_b_id}", "${data.terraform_remote_state.core.frankfurt_subnet_ec2_c_id}"]
  enable_deletion_protection = false
  idle_timeout               = 120

  tags = "${merge(map("Name", "${var.vault_cluster_name}-balancer"), var.custom_tags_common)}"
}

resource "aws_lb_target_group" "vault_cluster_tg" {
  name        = "${var.vault_cluster_name}"
  port        = "${var.lb_taget_group_port}"
  protocol    = "${var.lb_taget_group_protocol}"
  vpc_id      = "${data.terraform_remote_state.core.frankfurt_preprod_vpc_id}"
  target_type = "instance"

  health_check = {
    protocol            = "${var.lb_taget_group_hc_protocol}"
    path                = "${var.lb_taget_group_hc_path}"
    matcher             = "${var.lb_taget_group_hc_response}"
    interval            = "${var.lb_taget_group_interval}"
    timeout             = "${var.lb_taget_group_timeout}"
    healthy_threshold   = "${var.lb_taget_group_healthy_threshold}"
    unhealthy_threshold = "${var.lb_taget_group_unhealthy_threshold}"
  }
}

resource "aws_lb_target_group_attachment" "vault_backend" {
  count            = "${length(local.vault_cluster_subnets_ids)}"
  target_group_arn = "${aws_lb_target_group.vault_cluster_tg.arn}"
  target_id        = "${element(aws_instance.vault_node.*.id, count.index)}"
  port             = "${var.lb_taget_group_port}"
}

resource "aws_lb_listener" "vault_backend_redirect" {
  load_balancer_arn = "${aws_lb.vault_cluster_lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "vault_backend_forward" {
  load_balancer_arn = "${aws_lb.vault_cluster_lb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "${var.lb_ssl_policy}"
  certificate_arn   = "${var.lb_listener_forward_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.vault_cluster_tg.arn}"
  }
}
