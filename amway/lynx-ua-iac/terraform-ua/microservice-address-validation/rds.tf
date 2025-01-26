module "rds_pgsql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "rds-address-validation"

  engine                     = "postgres"
  engine_version             = "11.15"
  major_engine_version       = "11"
  instance_class             = "db.m5.large"
  allocated_storage          = 100
  max_allocated_storage      = 160
  storage_type               = "gp2"
  auto_minor_version_upgrade = false
  multi_az                   = false
  storage_encrypted          = true

  create_db_parameter_group = true
  create_db_subnet_group    = true
  family                    = "postgres11"
   
  snapshot_identifier = "snapshot-recovery"

  name     = "address_validation_qa_ua"
  username = var.microservice_db_user
  password = var.microservice_db_pass
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
      value        = "524288"
      apply_method = "pending-reboot"
    },
    {
      name         = "effective_cache_size"
      value        = "1572864"
      apply_method = "pending-reboot"
    },
    {
      name         = "maintenance_work_mem"
      value        = "1048576"
      apply_method = "pending-reboot"
    },
    {
      name  = "work_mem"
      value = "31457"
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

  publicly_accessible                 = false
  apply_immediately                   = true
  iam_database_authentication_enabled = false
  deletion_protection                 = false
  skip_final_snapshot                 = true

  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 7

  vpc_security_group_ids = [module.pgsql_rds_sg.security_group_id]
  subnet_ids             = data.terraform_remote_state.core.outputs.database_subnets

  tags = merge(local.amway_common_tags, local.amway_rds_specific_tags)
}
