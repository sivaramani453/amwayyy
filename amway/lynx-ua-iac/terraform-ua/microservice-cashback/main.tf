locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]

  amway_tags = "${map(
    "Terraform", "True",
    "Evironment", "DEV",
    "DataClassification", "Internal",
    "ApplicationID", "APP3150571"
  )}"
}

module "pgsql_rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "pgsql-rds-${var.pg_db_name}-sg"
  description = "Security group for PgSQL RDS instance"
  vpc_id      = data.terraform_remote_state.core.outputs.vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]

  tags = merge(map("Name", "pgsql-rds-${var.pg_db_name}-sg"), local.amway_tags)
}

module "rds_pgsql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "rds-cashback"

  engine                     = "postgres"
  engine_version             = "11.15"
  major_engine_version       = "11"
  instance_class             = "db.t3.micro"
  allocated_storage          = 40
  storage_encrypted          = true
  max_allocated_storage      = 120
  storage_type               = "gp2"
  auto_minor_version_upgrade = false
  multi_az                   = false

  create_db_parameter_group = true
  create_db_subnet_group    = true
  family                    = "postgres11"

  name     = "cashback_ua_qa"
  username = "cashback_user"
  password = "cashback_pass"
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
      name  = "synchronous_commit"
      value = "off"
    },
    {
      name         = "shared_buffers"
      value        = "131072"
      apply_method = "pending-reboot"
    },
    {
      name         = "effective_cache_size"
      value        = "393216"
      apply_method = "pending-reboot"
    },
    {
      name         = "maintenance_work_mem"
      value        = "262144"
      apply_method = "pending-reboot"
    },
    {
      name  = "work_mem"
      value = "5242"
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

  performance_insights_enabled        = true
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  publicly_accessible                 = false
  apply_immediately                   = true
  iam_database_authentication_enabled = false
  deletion_protection                 = false
  skip_final_snapshot                 = true

  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 3

  vpc_security_group_ids = [module.pgsql_rds_sg.security_group_id]
  subnet_ids             = data.terraform_remote_state.core.outputs.database_subnets

  tags = merge(map("Name", "pgsql-rds-${var.pg_db_name}"), local.amway_tags)
}
