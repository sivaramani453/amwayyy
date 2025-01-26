provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_ami" "sonarqube_ami" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["sonarqube-${var.ec2_tag_name_suffix}*"]
  }

  owners      = ["self"]
  most_recent = true
}

# EC2 Instance
resource "aws_instance" "sonarqube" {
  ami                         = "${data.aws_ami.sonarqube_ami.id}"
  availability_zone           = "${var.ec2_availability_zone}"
  ebs_optimized               = "${var.ec2_ebs_optimized}"
  instance_type               = "${var.ec2_instance_type}"
  monitoring                  = "${var.ec2_monitoring}"
  key_name                    = "${var.ec2_key_name}"
  subnet_id                   = "${var.ec2_subnet_id}"
  vpc_security_group_ids      = "${var.ec2_vpc_security_group_ids}"
  associate_public_ip_address = "${var.ec2_associate_public_ip_address}"
  source_dest_check           = "${var.ec2_source_dest_check}"

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    iops                  = "${var.root_volume_iops}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
  }

  tags {
    "Name" = "sonarqube-${var.ec2_tag_name_suffix}"
  }
}

# ALB
resource "aws_lb" "sonarqube" {
  name                       = "sonarqube-${var.ec2_tag_name_suffix}"
  internal                   = "${var.lb_is_internal}"
  load_balancer_type         = "${var.lb_type}"
  security_groups            = ["${var.ec2_vpc_security_group_ids}"]
  subnets                    = ["${var.lb_subnet_ids}"]
  enable_deletion_protection = "${var.lb_deletion_protection}"

  tags {
    Environment = "sonarqube-${var.ec2_tag_name_suffix}"
  }
}

resource "aws_lb_target_group" "sonarqube" {
  name        = "sonarqube-${var.ec2_tag_name_suffix}"
  port        = "${var.lb_taget_group_port}"
  protocol    = "${var.lb_taget_group_protocol}"
  vpc_id      = "${var.ec2_vpc_id}"
  target_type = "${var.lb_taget_group_type}"

  health_check = {
    protocol = "${var.lb_taget_group_hc_protocol}"
    path     = "${var.lb_taget_group_hc_path}"
    matcher  = "${var.lb_taget_group_hc_response}"
  }
}

resource "aws_lb_target_group_attachment" "sonarqube" {
  target_group_arn = "${aws_lb_target_group.sonarqube.arn}"
  target_id        = "${aws_instance.sonarqube.private_ip}"
  port             = "${var.lb_taget_group_port}"
}

resource "aws_lb_listener" "sonarqube" {
  load_balancer_arn = "${aws_lb.sonarqube.arn}"
  port              = "${var.lb_listener_port}"
  protocol          = "${var.lb_listener_protocol}"

  default_action {
    type = "${var.lb_listener_action}"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }

    target_group_arn = "${aws_lb_target_group.sonarqube.arn}"
  }
}

resource "aws_lb_listener" "sonarqube_forward" {
  load_balancer_arn = "${aws_lb.sonarqube.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = "arn:aws:acm:eu-central-1:860702706577:certificate/e5ebf7db-be9e-4f17-b391-b837bc9cd63d"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.sonarqube.arn}"
  }
}

# Route53
resource "aws_route53_record" "sonarqube" {
  zone_id = "${var.r53_zone_id}"
  name    = "${var.ec2_tag_name_suffix}.sonarqube.hybris.eia.amway.net"
  type    = "${var.r53_type}"

  alias {
    name                   = "${aws_lb.sonarqube.dns_name}"
    zone_id                = "${aws_lb.sonarqube.zone_id}"
    evaluate_target_health = "${var.r53_evaluate_hc}"
  }

  depends_on = ["aws_lb.sonarqube"]
}

resource "aws_route53_record" "sonarqube-zabbix" {
  zone_id = "${var.r53_zone_id}"
  name    = "${var.ec2_tag_name_suffix}.sonarqube.zabbix.hybris.eia.amway.net"
  type    = "${var.r53_type}"
  records = ["${aws_instance.sonarqube.private_ip}"]
  ttl     = "${var.r53_ttl}"
}
