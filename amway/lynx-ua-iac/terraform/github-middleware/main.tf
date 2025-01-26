module "alb_security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "2.9.0"
  name                = "EPAM-${var.service}-alb"
  description         = "Security group for github-middleware alb with HTTP and HTTPS ports open to the Internet"
  vpc_id              = "${data.terraform_remote_state.core.vpc.dev.id}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  tags                = "${local.tags}"
}

module "target_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "2.9.0"
  name        = "EPAM-${var.service}-target"
  description = "Security group for github-middleware targets"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  computed_ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${data.terraform_remote_state.core.vpc.dev.cidr_block}"
    },
  ]

  number_of_computed_ingress_with_cidr_blocks = 1

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 8888
      to_port                  = 8888
      protocol                 = "tcp"
      description              = "User-service ports"
      source_security_group_id = "${module.alb_security_group.this_security_group_id}"
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1
  egress_cidr_blocks                                       = ["0.0.0.0/0"]
  egress_rules                                             = ["all-all"]
  tags                                                     = "${local.tags}"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  load_balancer_name = "${var.service}"
  security_groups    = ["${module.alb_security_group.this_security_group_id}"]

  subnets = [
    "${data.terraform_remote_state.core.subnet.middleware_a.id}",
    "${data.terraform_remote_state.core.subnet.middleware_b.id}",
    "${data.terraform_remote_state.core.subnet.middleware_c.id}",
  ]

  vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"

  logging_enabled = false

  listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  https_listeners             = "${local.https_listeners}"
  https_listeners_count       = "${local.https_listeners_count}"

  target_groups          = "${local.target_groups}"
  target_groups_count    = "${local.target_groups_count}"
  target_groups_defaults = "${local.target_groups_defaults}"

  tags = "${local.tags}"
}

module "autoscaling_group" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.9.0"
  name    = "${var.service}"

  # Launch configuration
  lc_name = "${var.service}-lc"

  image_id          = "${data.aws_ami.ami.id}"
  instance_type     = "t2.micro"
  security_groups   = ["${module.target_security_group.this_security_group_id}"]
  enable_monitoring = false
  key_name          = "ansible_rsa"

  root_block_device = [
    {
      volume_size = "20"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name = "${var.service}-asg"

  vpc_zone_identifier = [
    "${data.terraform_remote_state.core.subnet.ci_a.id}",
    "${data.terraform_remote_state.core.subnet.ci_b.id}",
    "${data.terraform_remote_state.core.subnet.ci_c.id}",
  ]

  health_check_type         = "EC2"
  min_size                  = 3
  max_size                  = 3
  desired_capacity          = 3
  wait_for_capacity_timeout = 0

  target_group_arns = ["${module.alb.target_group_arns}"]
  tags_as_map       = "${local.tags}"
}

# Redirect port 80 to 443
resource "aws_lb_listener" "http_redirect" {
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

# Route 53 record to ALB
resource "aws_route53_record" "main" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "middleware.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.alb.dns_name}"
    zone_id                = "${module.alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}
