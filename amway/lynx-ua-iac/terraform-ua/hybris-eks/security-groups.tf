resource "aws_security_group" "hybris_eks-workers" {
  name_prefix = "hybris_eks-workers"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/16",
    ]
  }
  ingress {
    description = "Ingress HTTP"
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    description = "Ingress HTTPS"
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    ApplicationID = "APP3150571"
    Environment   = "Dev"
    DataClassification = "internal"
  }
}
