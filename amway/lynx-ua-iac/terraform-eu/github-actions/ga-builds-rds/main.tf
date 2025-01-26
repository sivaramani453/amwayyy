data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "ga-builds-rds-${terraform.workspace}-sg"
  description = "Security group for Github Actions Builds RDS"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["mysql-tcp"]

  tags = local.amway_common_tags
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "ga-builds-rds-${terraform.workspace}"

  engine                     = "mysql"
  engine_version             = "8.0.26"
  instance_class             = "db.m5.large"
  allocated_storage          = 20
  max_allocated_storage      = 200
  auto_minor_version_upgrade = true

  deletion_protection = true
  skip_final_snapshot = false
  multi_az            = true
  storage_encrypted   = true

  apply_immediately                   = false
  iam_database_authentication_enabled = false

  create_db_parameter_group = true
  create_db_subnet_group    = false
  db_subnet_group_name      = data.terraform_remote_state.core.outputs.frankfurt_subnet_rds_group

  family               = "mysql8.0"
  major_engine_version = "8.0"

  username               = "root"
  create_random_password = true
  random_password_length = 16
  port                   = "3306"

  vpc_security_group_ids = [module.db_sg.this_security_group_id]

  maintenance_window      = "Mon:23:30-Tue:00:30"
  backup_window           = "01:30-02:30"
  backup_retention_period = 3

  copy_tags_to_snapshot = true

  tags             = local.amway_common_tags
  db_instance_tags = local.amway_data_tags

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
  ]
}
