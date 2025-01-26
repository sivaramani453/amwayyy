resource "aws_db_subnet_group" "eia-coupons-rds-subnet-group" {
  name = "eia_coupons_subnet_groups"
  subnet_ids = data.terraform_remote_state.core.outputs.database_subnets
  description = "coupons subnetgroup"
  }

resource "aws_db_instance" "eia_coupons" {
  identifier             = "eia-coupons-db"
  instance_class         = "db.m5.xlarge"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = var.engine_version
  username               = var.root_username
  password               = var.root_password
  db_subnet_group_name   = aws_db_subnet_group.eia-coupons-rds-subnet-group.name
  vpc_security_group_ids = [module.pgsql_rds_sg.security_group_id]
  parameter_group_name   = "default.postgres11"
  publicly_accessible    = false
  skip_final_snapshot    = true
  
  copy_tags_to_snapshot = true
  deletion_protection = false
#  enabled_cloudwatch_logs_exports = ["postgresql"]
  iam_database_authentication_enabled = false
  iops = 0
  max_allocated_storage = 0
  multi_az = false
  option_group_name = "default:postgres-11"
  port = 5432
  storage_encrypted = true
  storage_type = "gp2"
  tags = local.tags
}
