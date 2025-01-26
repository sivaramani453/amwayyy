resource "aws_security_group" "rds" {
  name   = "gh-builds-info-rds-sg"
  vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "epam-kubernetes-cluster-rds"
    Terraform = "true"
  }
}
