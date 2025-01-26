provider "aws" {
  region  = "ap-south-1"
  version = "~> 2.5.0"
}

locals {
  tags = "${map(
    "Service", "kubernetes-cluster",
    "Environment", "dev",
    "Terraform", "true"
  )}"
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "ec2_cluster_etcd" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 1.0"

  name           = "epam-kubernetes-cluster-etcd"
  instance_count = "1"

  ami                    = "ami-06e44fa7c96be5987"
  instance_type          = "t3.medium"
  key_name               = "ansible_rsa"
  monitoring             = false
  use_num_suffix         = true
  vpc_security_group_ids = ["${aws_security_group.main.id}"]

  subnet_ids = ["${data.terraform_remote_state.core.subnet.mumbai_dev.mumbai_kubernetes.id}"]

  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 20
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ec2_cluster_worker" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 1.0"

  name           = "epam-kubernetes-cluster-worker"
  instance_count = "1"

  ami                    = "ami-06e44fa7c96be5987"
  instance_type          = "t3.xlarge"
  key_name               = "ansible_rsa"
  monitoring             = false
  use_num_suffix         = true
  vpc_security_group_ids = ["${aws_security_group.main.id}"]

  subnet_ids = ["${data.terraform_remote_state.core.subnet.mumbai_dev.mumbai_kubernetes.id}"]

  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 20
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "s3_bucket" {
  source       = "cloudposse/s3-bucket/aws"
  version      = "0.3.0"
  user_enabled = "true"
  name         = "india-cluster-etcd-backups"
  region       = "ap-south-1"
  stage        = "dev"
  namespace    = "amway"

  tags = "${local.tags}"
}

resource "aws_security_group" "main" {
  name   = "epam-kubernetes-cluster"
  vpc_id = "${data.terraform_remote_state.core.vpc.mumbai_dev.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.terraform_remote_state.core.vpc.dev.cidr_block}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = "true"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "epam-kubernetes-cluster"
    Terraform = "true"
  }
}

resource "aws_security_group" "rds" {
  name   = "epam-kubernetes-cluster-rds"
  vpc_id = "${data.terraform_remote_state.core.vpc.mumbai_dev.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = ["${aws_security_group.main.id}"]
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

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "india-microservices-db-dev"

  engine            = "mysql"
  engine_version    = "5.7.23"
  instance_class    = "db.t2.small"
  allocated_storage = 50

  name     = "dev"
  username = "bender"
  password = "thisIsVerySecureWayTo_storeDBpassw0rd"
  port     = "3306"

  vpc_security_group_ids = ["${aws_security_group.rds.id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = "${local.tags}"

  subnet_ids = [
    "${data.terraform_remote_state.core.subnet.mumbai_dev.mumbai_kubernetes_rds_a.id}",
    "${data.terraform_remote_state.core.subnet.mumbai_dev.mumbai_kubernetes_rds_b.id}",
  ]

  family               = "mysql5.7"
  major_engine_version = "5.7"

  skip_final_snapshot = "true"
  deletion_protection = "false"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    },
  ]
}
