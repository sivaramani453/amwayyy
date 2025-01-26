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
    "172.16.0.0/12",
  ]

  amway_tags = "${map(
        "Terraform", "True",
        "Evironment", "DEV",
        "DataClassification", "Internal",
        "ApplicationID", "APP3150571",
        "SEC-INFRA-13", "Appliance",
        "SEC-INFRA-14", "MSP",
        "ITAM-SAM", "MSP"
 )}"
}

resource "random_password" "pgsql_password" {
  length  = 16
  special = false
}

resource "random_password" "pgsql_user_password" {
  length  = 12
  special = false
}

data "aws_subnet" "kube-a" {
  id = "${data.terraform_remote_state.core.virginia.subnet.kubenetes_a.id}"
}

data "aws_subnet" "kube-b" {
  id = "${data.terraform_remote_state.core.virginia.subnet.kubenetes_b.id}"
}

data "aws_subnet" "kube-c" {
  id = "${data.terraform_remote_state.core.virginia.subnet.kubenetes_c.id}"
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

#  name        = "prod-vip-reports-db-sg"
  name        = "rds-${terraform.workspace}"
  description = "Security group for vip-reports database"
  vpc_id      = "${data.terraform_remote_state.core.virginia.prod_vpc.id}"

  ingress_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "${data.aws_subnet.kube-a.cidr_block}", "${data.aws_subnet.kube-b.cidr_block}", "${data.aws_subnet.kube-c.cidr_block}"]
  ingress_rules       = ["postgresql-tcp"]

  egress_rules = ["all-all"]
  
  tags = "${merge(map("Name", "rds-${terraform.workspace}"), local.amway_tags)}"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "1.31.0"

#  identifier = "prod-vip-reports-db"
  identifier = "rds-${terraform.workspace}"

  engine                     = "postgres"
  engine_version             = "10.17"
  family                     = "postgres10"
  major_engine_version       = "10"
  instance_class             = "db.m5.xlarge"
  allocated_storage          = 100
  max_allocated_storage      = 150
  storage_encrypted          = true
  auto_minor_version_upgrade = false

  username = "root"
  password = "${var.root_password != "" ? var.root_password : random_password.pgsql_password.result}"
  port     = "5432"

  vpc_security_group_ids = ["${module.db_security_group.this_security_group_id}"]
  multi_az               = true
  create_db_subnet_group = false
  db_subnet_group_name   = "${data.terraform_remote_state.core.virginia.subnet.rds_group}"

  apply_immediately = false

  # UTC timezone
  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 8

  performance_insights_enabled = true

  deletion_protection = true

  tags = "${merge(map("Name", "rds-${terraform.workspace}"), local.amway_tags)}"
}
