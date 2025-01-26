data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "achievers-club-db-sg"
  description = "Security group for AAC database"
  vpc_id      = "${data.terraform_remote_state.core.mumbai.prod_vpc.id}"

  ingress_cidr_blocks = ["${data.terraform_remote_state.core.mumbai.prod_vpc.cidr_block}"]
  ingress_rules       = ["mysql-tcp"]

  egress_rules = ["all-all"]
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "1.31.0"

  identifier = "achievers-club-db"

  engine                     = "mysql"
  engine_version             = "5.7.26"
  family                     = "mysql5.7"
  major_engine_version       = "5.7"
  instance_class             = "db.m5.large"
  allocated_storage          = 100
  max_allocated_storage      = 200
  auto_minor_version_upgrade = false

  username = "root"
  password = "${var.root_password}"
  port     = "3306"

  vpc_security_group_ids = ["${module.db_security_group.this_security_group_id}"]
  multi_az               = true
  create_db_subnet_group = false
  db_subnet_group_name   = "${data.terraform_remote_state.core.mumbai.subnet.rds_group}"

  apply_immediately = true

  # UTC timezone
  maintenance_window      = "Mon:18:30-Mon:19:30"
  backup_window           = "20:30-21:30"
  backup_retention_period = 8

  performance_insights_enabled = true

  deletion_protection = true

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

  tags = {
    Terraform = "true"
    Service   = "achievers-club"
  }
}
