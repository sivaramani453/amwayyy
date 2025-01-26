# EFS configuration

locals {
  efs_subnet_ids = ["${data.terraform_remote_state.core.subnet.virginia_dev.virginia_dev_a.id}", "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_dev_b.id}"]
}

resource "aws_efs_file_system" "main" {
  tags {
    Terraform = "True"
    Name      = "${var.name}"
  }
}

resource "aws_efs_mount_target" "main" {
  count          = "${length(local.efs_subnet_ids)}"
  file_system_id = "${aws_efs_file_system.main.id}"
  subnet_id      = "${element(local.efs_subnet_ids, count.index)}"

  security_groups = [
    "${aws_security_group.efs_sg.id}",
  ]
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.name}-sg"
  description = "Allows NFS traffic from and to ec2 instances within the vpc."
  vpc_id      = "${data.terraform_remote_state.core.vpc.virginia_dev.id}"

  tags {
    Terraform = "True"
    Name      = "${var.name}-sg"
  }
}

resource "aws_security_group_rule" "efs_mounts_in_2049" {
  type              = "ingress"
  security_group_id = "${aws_security_group.efs_sg.id}"

  protocol    = "tcp"
  from_port   = 2049
  to_port     = 2049
  cidr_blocks = ["${var.efs_allowed_ingress_cidrs}"]
}

resource "aws_security_group_rule" "efs_mounts_out_2049" {
  type              = "egress"
  security_group_id = "${aws_security_group.efs_sg.id}"

  protocol         = "tcp"
  from_port        = 2049
  to_port          = 2049
  cidr_blocks      = ["${var.efs_allowed_egress_cidrs}"]
  ipv6_cidr_blocks = ["${var.ipv6_efs_allowed_egress_cidrs}"]
}

resource "aws_route53_record" "efs_mount_target" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${aws_efs_file_system.main.id}.efs.hybris.eia.amway.net"
  ttl     = "300"
  type    = "A"

  records = ["${aws_efs_mount_target.main.*.ip_address}"]
}
