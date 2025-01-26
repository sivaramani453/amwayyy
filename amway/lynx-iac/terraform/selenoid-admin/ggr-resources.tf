resource "aws_security_group" "selenoid-ui-alb" {
  name   = "selenoid_ui_alb_access"
  vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"

  tags {
    "Terraform" = "true"
    "Name"      = "Selenoid"
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 4444
    to_port   = 4444
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }
}

resource "aws_security_group" "EIA-selenoid" {
  name   = "selenoid_instances_sg"
  vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"

  tags {
    "Terraform" = "true"
    "Name"      = "Selenoid"
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 4444
    to_port   = 4444
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.go-grid-router_allow_all_cidr_blocks}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.go-grid-router_cidr_blocks}"
  }
}

module "ggr-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  load_balancer_name = "${data.terraform_remote_state.core.project}-go-grid-router"
  security_groups    = ["${aws_security_group.selenoid-ui-alb.id}"]
  subnets            = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}", "${data.terraform_remote_state.core.subnet.core_c.id}"]
  vpc_id             = "${data.terraform_remote_state.core.vpc.dev.id}"

  load_balancer_is_internal = "true"
  logging_enabled           = "false"

  # tags                     = "${map("Environment", "test")}"
  # https_listeners          = "${list(map("certificate_arn", "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012", "port", 443))}"
  # https_listeners_count    = "1"

  http_tcp_listeners       = "${list(map("port", "4444", "protocol", "HTTP", "target_group_index", 0), map("port", "80", "protocol", "HTTP", "target_group_index", 1))}"
  http_tcp_listeners_count = "2"
  target_groups            = "${list(map("name", "ggr-nodes", "backend_protocol", "HTTP", "backend_port", "4444", "health_check_path", "/ping"), map("name", "selenoid-ui", "backend_protocol", "HTTP", "backend_port", "8080"))}"
  target_groups_count      = "2"
}

# resource "aws_route53_record" "selenoid-nodes" {
#
#   zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
#   name    = "node${count.index}.selenoid-grid.hybris.eia.amway.net"
#   type    = "A"
#   ttl     = "300"
#   records = ["${module.ggr-alb.dns_name}"]
# }

resource "aws_route53_record" "selenoid-grid" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "node${count.index}.selenoid-grid.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.ggr-alb.dns_name}"
    zone_id                = "${module.ggr-alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}
