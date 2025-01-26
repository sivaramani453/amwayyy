module "alb_security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "2.9.0"
  name                = "EPAM-${var.service}-alb"
  description         = "Security group for scale-agents alb"
  vpc_id              = "${data.terraform_remote_state.core.vpc.dev.id}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  tags                = "${local.tags}"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  load_balancer_name        = "${var.service}"
  load_balancer_is_internal = "true"
  security_groups           = ["${module.alb_security_group.this_security_group_id}"]

  subnets = [
    "${data.terraform_remote_state.core.subnet.core_a.id}",
    "${data.terraform_remote_state.core.subnet.core_b.id}",
  ]

  vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"

  logging_enabled = "false"

  target_groups = "${list(
                        map("name", "${var.service}",
                            "backend_protocol", "HTTP",
                            "backend_port", "8080",
                            "slow_start", 0
                        )
  )}"

  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"

  target_groups_count = 1

  target_groups_defaults = "${map(
    "cookie_duration", 86400,
    "deregistration_delay", 300,
    "health_check_interval", 15,
    "health_check_healthy_threshold", 3,
    "health_check_path", "/health",
    "health_check_port", "traffic-port",
    "health_check_timeout", 10,
    "health_check_unhealthy_threshold", 3,
    "health_check_matcher", "200",
    "stickiness_enabled", "false",
    "target_type", "ip",
    "slow_start", 0
  )}"

  tags = "${map(
                "Service", "${var.service}",
                "Environment", "${var.environment}",
                "Project", "${data.terraform_remote_state.core.project}"
               )
  }"
}

# allow access from ALB to ECS
resource "aws_security_group_rule" "add_ingress_from_alb_security_group" {
  security_group_id = "${module.ecs-fargate.security_group_id}"
  type              = "ingress"

  source_security_group_id = "${module.alb_security_group.this_security_group_id}"
  description              = "Allow traffic from ALB"

  from_port = 0
  to_port   = 0
  protocol  = -1
}

resource "aws_cloudwatch_log_group" "common" {
  name              = "${data.terraform_remote_state.core.project}-${var.service}"
  retention_in_days = "14"

  tags = "${local.tags}"
}
