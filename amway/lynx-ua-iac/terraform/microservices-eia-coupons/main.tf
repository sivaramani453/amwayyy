data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "frankfurt_cluster" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "frankfurt-cluster.tfstate"
    region = "eu-central-1"
  }
}

module "rds_pgsql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "eia-coupons-${var.env_prefix}-rds"

  engine                     = "postgres"
  engine_version             = "10.4"
  major_engine_version       = "10"
  instance_class             = "db.m5.large"
  allocated_storage          = 100
  max_allocated_storage      = 120
  storage_type               = "gp2"
  auto_minor_version_upgrade = false
  multi_az                   = false

  create_db_parameter_group = true
  create_db_subnet_group    = true
  family                    = "postgres10"

  username = "root"
  password = "${var.root_password}"
  port     = "5432"

  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  apply_immediately                   = false
  iam_database_authentication_enabled = false
  deletion_protection                 = true

  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 7

  vpc_security_group_ids = ["${module.pgsql_rds_sg.this_security_group_id}"]
  subnet_ids             = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}", "${data.terraform_remote_state.core.subnet.core_c.id}"]

  tags = {
    Terraform  = "true"
    Evironment = "eia-coupons-${var.env_prefix}"
  }
}

resource "aws_route53_record" "microservice_url" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "coupons-${var.env_prefix}.${data.terraform_remote_state.core.route53.zone.name}"
  type    = "A"

  alias {
    name                   = "${data.terraform_remote_state.frankfurt_cluster.ingress_endpoint}"
    zone_id                = "${data.terraform_remote_state.frankfurt_cluster.lb_zone_id}"
    evaluate_target_health = false
  }
}

module "pgsql_rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "pgsql-rds-eia-coupons-${var.env_prefix}-sg"
  description = "Security group for PgSQL RDS instance"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = ["${data.terraform_remote_state.core.vpc.dev.cidr_block}", "10.0.0.0/8"]
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]
}
