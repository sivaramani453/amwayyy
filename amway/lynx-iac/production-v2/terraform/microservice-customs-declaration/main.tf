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

  name        = "pgsql-rds-customs-declaration-sg"
  description = "Security group for PgSQL RDS instance"
  vpc_id      = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"

  ingress_cidr_blocks = ["${local.vpn_subnet_cidrs}"]
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "rds-customs-declaration"

  engine                     = "postgres"
  engine_version             = "10.6"
  major_engine_version       = "10"
  instance_class             = "db.m5.large"
  allocated_storage          = 100
  max_allocated_storage      = 200
  auto_minor_version_upgrade = false
  multi_az                   = true
  storage_encrypted          = true

  create_db_parameter_group = true
  create_db_subnet_group    = false
  db_subnet_group_name      = "${data.terraform_remote_state.core.frankfurt.subnet.rds_group}"
  family                    = "postgres10"

  username = "root"
  password = "${var.root_password}"
  port     = "5432"

  parameters = [
    {
      name  = "autovacuum_analyze_scale_factor"
      value = "0.1"
    },
    {
      name  = "autovacuum_vacuum_scale_factor"
      value = "0.2"
    },
    {
      name  = "autovacuum_naptime"
      value = "60"
    },
    {
      name         = "shared_buffers"
      value        = "262144"
      apply_method = "pending-reboot"
    },
    {
      name         = "effective_cache_size"
      value        = "786432"
      apply_method = "pending-reboot"
    },
    {
      name         = "maintenance_work_mem"
      value        = "524288"
      apply_method = "pending-reboot"
    },
    {
      name  = "work_mem"
      value = "20971"
    },
    {
      name         = "max_connections"
      value        = "100"
      apply_method = "pending-reboot"
    },
    {
      name  = "random_page_cost"
      value = "1.1"
    },
    {
      name  = "effective_io_concurrency"
      value = "200"
    },
  ]

  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  apply_immediately                   = false
  iam_database_authentication_enabled = false
  deletion_protection                 = true

  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 7

  vpc_security_group_ids = ["${module.db_security_group.this_security_group_id}"]

  tags = {
    Terraform  = "true"
    Evironment = "customs-declaration"
  }
}
