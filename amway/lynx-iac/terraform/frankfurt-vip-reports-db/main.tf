data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "rds_pgsql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "${terraform.workspace}"

  engine            = "postgres"
  engine_version    = "10.6"
  instance_class    = "db.t3.medium"
  allocated_storage = 100
  storage_encrypted = false

  username = "root"
  password = "${var.root_password}"
  port     = "5432"

  vpc_security_group_ids = ["${module.pgsql_rds_sg.this_security_group_id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  enabled_cloudwatch_logs_exports = ["postgresql"]
  performance_insights_enabled    = true

  tags = "${local.tags}"

  subnet_ids = [
    "${data.terraform_remote_state.core.subnet.core_a.id}",
    "${data.terraform_remote_state.core.subnet.core_b.id}",
  ]

  family               = "postgres10"
  major_engine_version = "10.6"

  skip_final_snapshot = "true"
  deletion_protection = "false"
}
