data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

#module "rds_pgsql" {
#  source  = "terraform-aws-modules/rds/aws"
#  version = "~> 3.0"

#  create_db_instance = false
#  create_db_subnet_group = false
#  db_subnet_group_name = "eia-vip-reports-qa-20200122114829874900000002"
#  db_subnet_group_use_name_prefix = false

#  create_db_parameter_group = false
#  parameter_group_name = "default.postgres10"
  
#  identifier = "eia-vip-reports"

#  engine            = "postgres"
#  engine_version    = "10.15"
#  instance_class    = "db.t3.medium"
#  allocated_storage = 100
#  storage_encrypted = true

#  username = "root"
#  password = var.root_password
#  port     = 5432

#  vpc_security_group_ids = ["sg-0b2464367e2fbbbf5"]

#  maintenance_window = "Mon:00:00-Mon:03:00"
#  backup_window      = "03:00-06:00"

#  enabled_cloudwatch_logs_exports = ["postgresql"]
#  performance_insights_enabled    = true

#  tags = local.tags

#  subnet_ids = [
#    "subnet-03f31d00ae084e534",
#    "subnet-08a3751ab0085dfa6",
#  ]

#  family               = "postgres10"
#  major_engine_version = "10.15"

#  skip_final_snapshot = "true"
#  deletion_protection = "false"
#}

resource "aws_db_instance" "vip_reports" {
  identifier             = "eia-vip-reports"
  instance_class         = "db.t3.medium"
  allocated_storage      = 100
  engine                 = "postgres"
  engine_version         = "10.15"
  username               = "root"
  password               = var.root_password
  db_subnet_group_name   = "eia-vip-reports-qa-20200122114829874900000002"
  vpc_security_group_ids = ["sg-0b2464367e2fbbbf5"]
  parameter_group_name   = "default.postgres10"
  publicly_accessible    = false
  skip_final_snapshot    = true
  
  copy_tags_to_snapshot = true
  deletion_protection = false
  enabled_cloudwatch_logs_exports = ["postgresql"]
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
