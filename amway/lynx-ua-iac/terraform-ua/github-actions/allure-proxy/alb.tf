resource "aws_lb" "allure_lb" {
  name                       = "allure-proxy-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = ["${module.alb_security_group.this_security_group_id}"]
  subnets                    = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]
  enable_deletion_protection = false
  idle_timeout               = 120

  tags = "${local.tags}"
}

resource "aws_lb_target_group" "asg_tg" {
  name        = "allure-proxy-tg"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"
  target_type = "instance"

  health_check = {
    protocol            = "HTTP"
    path                = "/status"
    matcher             = 200
    interval            = 30
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "redirect_80_443" {
  load_balancer_arn = "${aws_lb.allure_lb.arn}"
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

resource "aws_lb_listener" "allure_backend_fw" {
  load_balancer_arn = "${aws_lb.allure_lb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = ""
  certificate_arn   = "${var.cert_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.asg_tg.arn}"
  }
}

# Create route53 record with alias to ALB
resource "aws_route53_record" "alias" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${var.dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.allure_lb.dns_name}"
    zone_id                = "${aws_lb.allure_lb.zone_id}"
    evaluate_target_health = true
  }
}
