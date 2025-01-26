resource "aws_security_group" "zabbix-server" {
  vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow ssh within private ip range"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow web within private ip range"
  }

  ingress {
    from_port   = 10050
    to_port     = 10052
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow zabbix within private ip range"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "zabbix-server-sg"
    Terraform = "true"
  }
}
