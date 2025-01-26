resource "aws_security_group" "kube_workers" {
  name   = "eks-v2-workers-custom-sg"
  vpc_id = data.terraform_remote_state.core.outputs.vpc_id

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]
    description = "Allow NodePorts"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "eks-v2-workers-custom-sg"
    Terraform = "true"
  }
}

