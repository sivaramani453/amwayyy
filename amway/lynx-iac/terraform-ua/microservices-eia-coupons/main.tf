resource "aws_db_instance" "eia_coupons" {
  identifier             = "eia-coupons-db"
  instance_class         = "db.m5.xlarge"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "10.15"
  username               = "coupon_user"
#  password               = var.root_password
  db_subnet_group_name   = "rds-bank-identification-qa-20200901100353631900000001"
  vpc_security_group_ids = ["sg-0a19efa2675c41869"]
  parameter_group_name   = "default.postgres10"
  publicly_accessible    = false
  skip_final_snapshot    = true
  
  copy_tags_to_snapshot = true
  deletion_protection = false
#  enabled_cloudwatch_logs_exports = ["postgresql"]
  iam_database_authentication_enabled = false
  iops = 0
  max_allocated_storage = 0
  multi_az = false
  option_group_name = "default:postgres-10"
  port = 5432
  storage_encrypted = true
  storage_type = "gp3"
  tags = local.tags
}
