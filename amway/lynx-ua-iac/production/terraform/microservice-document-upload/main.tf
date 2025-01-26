data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "random_password" "pgsql_password" {
  length  = 16
  special = false
}

locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]

  amway_tags = "${map(
         "Terraform", "True",
         "Evironment", "PROD",
         "DataClassification", "Internal",
         "ApplicationID", "APP3150571"
 )}"
}

module "pgsql_rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "pgsql-rds-${terraform.workspace}-sg"
  description = "Security group for PgSQL RDS instance"
  vpc_id      = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]

  tags = "${merge(map("Name", "pgsql-rds-${terraform.workspace}-sg"), local.amway_tags)}"
}

module "rds_pgsql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "rds-${terraform.workspace}"

  engine                     = "postgres"
  engine_version             = "${var.engine_version}"
  major_engine_version       = "${var.major_engine_version}"
  instance_class             = "db.t3.medium"
  allocated_storage          = 40
  max_allocated_storage      = 120
  storage_type               = "gp2"
  auto_minor_version_upgrade = false
  multi_az                   = true

  create_db_parameter_group = true
  create_db_subnet_group    = false
  db_subnet_group_name      = "${data.terraform_remote_state.core.frankfurt.subnet.rds_group}"
  family                    = "postgres11"

  username = "root"
  password = "${var.root_password != "" ? var.root_password : random_password.pgsql_password.result}"
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
      name         = "max_connections"
      value        = "100"
      apply_method = "pending-reboot"
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

  apply_immediately                   = false
  iam_database_authentication_enabled = false
  deletion_protection                 = true

  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 3

  vpc_security_group_ids = ["${module.pgsql_rds_sg.this_security_group_id}"]

  tags = "${merge(map("Name", "pgsql-rds-${terraform.workspace}"), local.amway_tags)}"
}

# S3 buckets
module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.3.0"

  user_enabled       = "false"
  name               = "microservice-${terraform.workspace}-rukz"
  region             = "eu-central-1"
  stage              = "prod"
  namespace          = "amway"
  versioning_enabled = "false"

  tags {
    Terraform          = "true"
    ApplicationID      = "APP3150571"
    DataClassification = "internal"
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = "${module.s3_bucket.bucket_id}"
  policy = "${data.aws_iam_policy_document.bucket-policy-doc.json}"
}

data "aws_iam_policy_document" "bucket-policy-doc" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${var.AWS_user_arn}"]
    }

    resources = [
      "${module.s3_bucket.bucket_arn}/*",
      "${module.s3_bucket.bucket_arn}",
    ]
  }
}
