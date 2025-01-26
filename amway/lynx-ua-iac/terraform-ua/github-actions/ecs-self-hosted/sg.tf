resource "aws_security_group" "sg" {
  name   = "${var.cluster_name}-sg"
  vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow ssh within private ip range"
  }

  ingress {
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    self        = true
    description = "Allow docker connections within same sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.cluster_name}-sg"
    Terraform = "true"
  }
}
