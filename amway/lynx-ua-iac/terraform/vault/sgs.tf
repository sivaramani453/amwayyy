# LB

resource "aws_security_group" "vault_cluster_sg_lb" {
  name        = "${var.vault_cluster_name}-sg-lb"
  description = "Allow traffic into the vault cluster lb"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  tags = "${merge(map("Name", "${var.vault_cluster_name}-sg-lb"), var.custom_tags_common)}"
}

resource "aws_security_group_rule" "vault_cluster_lb_in_80" {
  type              = "ingress"
  security_group_id = "${aws_security_group.vault_cluster_sg_lb.id}"

  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["${var.lb_allowed_ingress_cidrs}"]
}

resource "aws_security_group_rule" "vault_cluster_lb_in_443" {
  type              = "ingress"
  security_group_id = "${aws_security_group.vault_cluster_sg_lb.id}"

  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["${var.lb_allowed_ingress_cidrs}"]
}

resource "aws_security_group_rule" "vault_cluster_lb_out_8200" {
  type              = "egress"
  security_group_id = "${aws_security_group.vault_cluster_sg_lb.id}"

  protocol                 = "tcp"
  from_port                = 8200
  to_port                  = 8200
  source_security_group_id = "${aws_security_group.vault_cluster_sg_ec2.id}"
}

# EC2

resource "aws_security_group" "vault_cluster_sg_ec2" {
  name        = "${var.vault_cluster_name}-sg-ec2"
  description = "Allow traffic from lb to ec2 and ec2 to ec2"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  tags = "${merge(map("Name", "${var.vault_cluster_name}-sg-ec2"), var.custom_tags_common)}"
}

resource "aws_security_group_rule" "vault_cluster_ec2_in_8200" {
  type              = "ingress"
  security_group_id = "${aws_security_group.vault_cluster_sg_ec2.id}"

  protocol                 = "tcp"
  from_port                = 8200
  to_port                  = 8200
  source_security_group_id = "${aws_security_group.vault_cluster_sg_lb.id}"
}

resource "aws_security_group_rule" "vault_cluster_ec2_in_8201" {
  type              = "ingress"
  security_group_id = "${aws_security_group.vault_cluster_sg_ec2.id}"

  protocol  = "tcp"
  from_port = 8201
  to_port   = 8201
  self      = true
}

resource "aws_security_group_rule" "vault_cluster_ec2_out_all" {
  type              = "egress"
  security_group_id = "${aws_security_group.vault_cluster_sg_ec2.id}"

  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
