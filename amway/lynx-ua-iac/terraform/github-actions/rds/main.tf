locals {
  tags {
    Environment = "dev"
    Terraform   = "true"
  }
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "gh-builds-info"

  engine            = "mysql"
  engine_version    = "5.7.23"
  instance_class    = "db.t3.small"
  allocated_storage = 50

  name     = "dev"
  username = "gh"
  password = "${var.db_password}"
  port     = "3306"

  vpc_security_group_ids = ["${aws_security_group.rds.id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = "${local.tags}"

  subnet_ids = ["subnet-06f0874edb9d3e9b2", "subnet-03017c3996406c3c2"]

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
