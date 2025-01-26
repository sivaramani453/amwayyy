resource "aws_instance" "backend_node_1" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_1}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_hybris}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_be1}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-BE1"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "backend_node_2" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_2}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_hybris}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_b.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_be2}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-BE2"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "frontend_node_1" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_1}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_hybris}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_fe1}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-FE1"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "frontend_node_2" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_2}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_hybris}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_b.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_fe2}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-FE2"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "frontend_node_3" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_1}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_hybris}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_fe3}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-FE3"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "frontend_node_4" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_2}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_hybris}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_b.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_fe4}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-FE4"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "order_fulfillment_node_1" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_1}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_hybris}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_of1}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-OF1"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "order_fulfillment_node_2" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_2}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_hybris}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_b.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_of2}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-OF2"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "solr_master_node" {
  ami                         = "${data.aws_ami.solr_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_1}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_solr}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_solr_master}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-SOLR-MASTER"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "solr_slave_a_node" {
  ami                         = "${data.aws_ami.solr_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_1}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_solr}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_solr_slave_a}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-SOLR-SLAVE-A"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_instance" "solr_slave_b_node" {
  ami                         = "${data.aws_ami.solr_ami.id}"
  availability_zone           = "${var.ec2_availability_zone_2}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type_solr}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_b.id}"
  vpc_security_group_ids      = ["${aws_security_group.perf_sg.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_solr_slave_b}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"     = "${var.ec2_env_name}-SOLR-SLAVE-B"
    "Schedule" = "daily_stop_21:00"
  }
}

resource "aws_volume_attachment" "media_attachment" {
  device_name = "${var.media_volume_device_name}"
  volume_id   = "${data.aws_ebs_volume.media_volume.id}"
  instance_id = "${aws_instance.backend_node_2.id}"
}

# Security group

resource "aws_security_group" "perf_sg" {
  name        = "perf-environment"
  description = "Allow inbound traffic from Amway network"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "perf-environment"
  }
}

# ALB frontend
resource "aws_lb" "frontend" {
  name                       = "${var.ec2_env_name}-frontend"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.perf_sg.id}"]
  subnets                    = ["${data.terraform_remote_state.core.subnet.env_a.id}", "${data.terraform_remote_state.core.subnet.env_b.id}"]
  enable_deletion_protection = false
  idle_timeout               = 120
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.ec2_env_name}-frontend"
  port        = "${var.lb_taget_group_port}"
  protocol    = "${var.lb_taget_group_protocol}"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"
  target_type = "instance"

  health_check = {
    protocol = "${var.lb_taget_group_hc_protocol}"
    path     = "${var.lb_taget_group_hc_path}"
    matcher  = "${var.lb_taget_group_hc_response}"
  }

  stickiness = {
    type            = "lb_cookie"
    cookie_duration = "${var.lb_taget_group_stickiness_cookie_duration}"
    enabled         = true
  }
}

resource "aws_lb_target_group_attachment" "frontend1" {
  target_group_arn = "${aws_lb_target_group.frontend.arn}"
  target_id        = "${aws_instance.frontend_node_1.id}"
  port             = "${var.lb_taget_group_port}"
}

resource "aws_lb_target_group_attachment" "frontend2" {
  target_group_arn = "${aws_lb_target_group.frontend.arn}"
  target_id        = "${aws_instance.frontend_node_2.id}"
  port             = "${var.lb_taget_group_port}"
}

resource "aws_lb_target_group_attachment" "frontend3" {
  target_group_arn = "${aws_lb_target_group.frontend.arn}"
  target_id        = "${aws_instance.frontend_node_3.id}"
  port             = "${var.lb_taget_group_port}"
}

resource "aws_lb_target_group_attachment" "frontend4" {
  target_group_arn = "${aws_lb_target_group.frontend.arn}"
  target_id        = "${aws_instance.frontend_node_4.id}"
  port             = "${var.lb_taget_group_port}"
}

resource "aws_lb_listener" "frontend_redirect" {
  load_balancer_arn = "${aws_lb.frontend.arn}"
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

resource "aws_lb_listener" "frontend_forward" {
  load_balancer_arn = "${aws_lb.frontend.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${var.lb_listener_forward_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.frontend.arn}"
  }
}

# ALB backend
resource "aws_lb" "backend" {
  name                       = "${var.ec2_env_name}-backend"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.perf_sg.id}"]
  subnets                    = ["${data.terraform_remote_state.core.subnet.env_a.id}", "${data.terraform_remote_state.core.subnet.env_b.id}"]
  enable_deletion_protection = false
  idle_timeout               = 120
}

resource "aws_lb_target_group" "backend" {
  name        = "${var.ec2_env_name}-backend"
  port        = "${var.lb_taget_group_port}"
  protocol    = "${var.lb_taget_group_protocol}"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"
  target_type = "instance"

  health_check = {
    protocol = "${var.lb_taget_group_hc_protocol}"
    path     = "${var.lb_taget_group_hc_path}"
    matcher  = "${var.lb_taget_group_hc_response}"
  }

  stickiness = {
    type            = "lb_cookie"
    cookie_duration = "${var.lb_taget_group_stickiness_cookie_duration}"
    enabled         = true
  }
}

resource "aws_lb_target_group_attachment" "backend1" {
  target_group_arn = "${aws_lb_target_group.backend.arn}"
  target_id        = "${aws_instance.backend_node_1.id}"
  port             = "${var.lb_taget_group_port}"
}

resource "aws_lb_target_group_attachment" "backend2" {
  target_group_arn = "${aws_lb_target_group.backend.arn}"
  target_id        = "${aws_instance.backend_node_2.id}"
  port             = "${var.lb_taget_group_port}"
}

resource "aws_lb_listener" "backend_redirect" {
  load_balancer_arn = "${aws_lb.backend.arn}"
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

resource "aws_lb_listener" "backend_forward" {
  load_balancer_arn = "${aws_lb.backend.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${var.lb_listener_forward_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.backend.arn}"
  }
}

# Route 53
resource "aws_route53_record" "backend_url" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "admin-${var.ec2_env_name}.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${aws_lb.backend.dns_name}"
    zone_id                = "${aws_lb.backend.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "front_urls" {
  count   = "${var.r53_records_count}"
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${var.ec2_env_name}.${element(var.r53_countries, count.index)}.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${aws_lb.frontend.dns_name}"
    zone_id                = "${aws_lb.frontend.zone_id}"
    evaluate_target_health = true
  }
}
