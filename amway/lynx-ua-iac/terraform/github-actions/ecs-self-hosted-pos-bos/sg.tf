resource "aws_security_group" "sg" {
  vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow ssh within private ip range"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.amway_common_tags, local.tags)}"
}
