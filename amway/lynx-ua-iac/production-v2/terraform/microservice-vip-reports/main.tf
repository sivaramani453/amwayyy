data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-ru-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "rds-vip-reports-db-sg"
  description = "Security group for eia-blocks database"
  vpc_id      = "${data.terraform_remote_state.core.virginia.prod_vpc.id}"

  ingress_cidr_blocks = ["${local.vpn_subnet_cidrs}"]
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "rds-vip-reports-db"

  engine                     = "postgres"
  engine_version             = "10.6"
  family                     = "postgres10"
  major_engine_version       = "10"
  instance_class             = "db.m5.xlarge"
  allocated_storage          = 100
  max_allocated_storage      = 150
  auto_minor_version_upgrade = false
  multi_az                   = true
  storage_encrypted          = true

  username = "root"
  password = "${var.root_password}"
  port     = "5432"

  vpc_security_group_ids    = ["${module.db_security_group.this_security_group_id}"]
  create_db_parameter_group = true
  create_db_subnet_group    = false
  db_subnet_group_name      = "${data.terraform_remote_state.core.virginia.subnet.rds_group}"

  apply_immediately = false

  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 8

  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  deletion_protection = true

  tags = {
    Terraform = "true"
  }
}
