data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "core-eks" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "eks-v2/core.tfstate"
    region = "eu-central-1"
  }
}

resource "random_password" "mssql_password" {
  length  = 16
  special = false
}

module "mssql_rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "mssql-rds-${terraform.workspace}-sg"
  description = "Security group for MSSQL RDS instance"
  vpc_id      = "${data.terraform_remote_state.core-eks.vpc_id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["mssql-tcp"]

  egress_rules = ["all-all"]

  tags = "${local.custom_tags_common}"
}

module "rds_mssql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "rds-${terraform.workspace}"

  engine                     = "sqlserver-ex"
  engine_version             = "13.00.5598.27.v1"
  major_engine_version       = "13.00"
  instance_class             = "db.t3.small"
  allocated_storage          = 20
  auto_minor_version_upgrade = false
  multi_az                   = false

  create_db_parameter_group = true
  create_db_subnet_group    = true
  family                    = "sqlserver-ex-13.0"

  username = "root"
  password = "${var.root_password != "" ? var.root_password : random_password.mssql_password.result}"
  port     = "1433"

  performance_insights_enabled = false

  apply_immediately                   = false
  iam_database_authentication_enabled = false
  deletion_protection                 = false

  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 2

  vpc_security_group_ids = ["${module.mssql_rds_sg.this_security_group_id}"]
  subnet_ids             = "${data.terraform_remote_state.core-eks.database_subnets}"

  tags = "${merge(local.custom_tags_common, local.custom_tags_specific)}"
}
