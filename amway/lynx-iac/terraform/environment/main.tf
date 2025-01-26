resource "aws_instance" "backend_node_1" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${data.aws_security_group.main.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_be1}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"             = "${var.ec2_env_name}-BE1"
    "zabbix"           = "true"
    "zabbix_groups"    = "${var.ec2_env_name}-group,aws-discovered-hosts"
    "zabbix_templates" = "Template OS Linux,Hybris data,Template App Generic Java JMX"
    "zabbix_jmx"       = "true"
  }
}

resource "aws_instance" "backend_node_2" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${data.aws_security_group.main.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_be2}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"             = "${var.ec2_env_name}-BE2"
    "zabbix"           = "true"
    "zabbix_groups"    = "${var.ec2_env_name}-group,aws-discovered-hosts"
    "zabbix_templates" = "Template OS Linux,Hybris data,Template App Generic Java JMX"
    "zabbix_jmx"       = "true"
  }
}

resource "aws_instance" "frontend_node_1" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${data.aws_security_group.main.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_fe1}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"             = "${var.ec2_env_name}-FE1"
    "zabbix"           = "true"
    "zabbix_groups"    = "${var.ec2_env_name}-group,aws-discovered-hosts"
    "zabbix_templates" = "Template OS Linux,Hybris data,Template App Generic Java JMX,Template App Apache Tomcat JMX"
    "zabbix_jmx"       = "true"
  }
}

resource "aws_instance" "frontend_node_2" {
  ami                         = "${data.aws_ami.env_ami.id}"
  availability_zone           = "${var.ec2_availability_zone}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_instance_type}"
  monitoring                  = false
  subnet_id                   = "${data.terraform_remote_state.core.subnet.env_a.id}"
  vpc_security_group_ids      = ["${data.aws_security_group.main.id}"]
  associate_public_ip_address = false
  private_ip                  = "${var.ec2_private_ip_fe2}"
  source_dest_check           = true

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    "Name"             = "${var.ec2_env_name}-FE2"
    "zabbix"           = "true"
    "zabbix_groups"    = "${var.ec2_env_name}-group,aws-discovered-hosts"
    "zabbix_templates" = "Template OS Linux,Hybris data,Template App Generic Java JMX,Template App Apache Tomcat JMX"
    "zabbix_jmx"       = "true"
  }
}

resource "aws_volume_attachment" "media_attachment" {
  device_name = "${var.media_volume_device_name}"
  volume_id   = "${data.aws_ebs_volume.media_volume.id}"
  instance_id = "${aws_instance.backend_node_2.id}"
}

resource "aws_volume_attachment" "db_attachment" {
  device_name = "${var.db_volume_device_name}"
  volume_id   = "${data.aws_ebs_volume.db_volume.id}"
  instance_id = "${aws_instance.backend_node_2.id}"
  depends_on  = ["aws_volume_attachment.media_attachment"]
}

# ALB frontend
resource "aws_lb" "frontend" {
  name                       = "${var.ec2_env_name}-frontend"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = ["${data.aws_security_group.main.id}"]
  subnets                    = ["${var.lb_subnet_ids}"]
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

resource "aws_lb_target_group" "frontend-storybook" {
  name        = "${var.ec2_env_name}-frontend-storybook"
  port        = "${var.lb_taget_group_port_storybook}"
  protocol    = "${var.lb_taget_group_protocol_storybook}"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"
  target_type = "instance"

  health_check = {
    protocol = "${var.lb_taget_group_hc_protocol_storybook}"
    path     = "${var.lb_taget_group_hc_path_storybook}"
    matcher  = "${var.lb_taget_group_hc_response_storybook}"
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

resource "aws_lb_target_group_attachment" "frontend1_sb" {
  target_group_arn = "${aws_lb_target_group.frontend-storybook.arn}"
  target_id        = "${aws_instance.frontend_node_1.id}"
  port             = "${var.lb_taget_group_port_storybook}"
}

resource "aws_lb_target_group_attachment" "frontend2_sb" {
  target_group_arn = "${aws_lb_target_group.frontend-storybook.arn}"
  target_id        = "${aws_instance.frontend_node_2.id}"
  port             = "${var.lb_taget_group_port_storybook}"
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

resource "aws_lb_listener" "frontend_forward_storybook" {
  load_balancer_arn = "${aws_lb.frontend.arn}"
  port              = 9090
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.frontend-storybook.arn}"
  }
}

# ALB backend
resource "aws_lb" "backend" {
  name                       = "${var.ec2_env_name}-backend"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = ["${data.aws_security_group.main.id}"]
  subnets                    = ["${var.lb_subnet_ids}"]
  enable_deletion_protection = false
  idle_timeout               = 300
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
