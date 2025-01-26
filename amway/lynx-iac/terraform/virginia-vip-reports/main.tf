data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "kubernetes-cluster" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "virginia-cluster.tfstate"
    region = "eu-central-1"
  }
}

module "sg_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "epam-vip-reports-rds"
  description = "Security group vip-reports RDS"
  vpc_id      = "${data.terraform_remote_state.core.vpc.virginia_dev.id}"

  ingress_cidr_blocks = ["${data.terraform_remote_state.core.vpc.virginia_dev.cidr_block}"]
  ingress_rules       = ["postgresql-tcp"]

  egress_rules = ["all-all"]

  tags = "${merge(local.amway_common_tags, local.data_tags, local.tags)}"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "eia-vip-report-test"

  engine            = "postgres"
  engine_version    = "10.6"
  instance_class    = "db.t3.medium"
  allocated_storage = 300
  storage_encrypted = false

  name     = "reports"
  username = "vip_reports_user"
  password = "vip_reports_pass"
  port     = "5432"

  vpc_security_group_ids = ["${module.sg_rds.this_security_group_id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = "${merge(local.amway_common_tags, local.data_tags, local.tags)}"

  subnet_ids = [
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_dev_a.id}",
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_dev_b.id}",
  ]

  family               = "postgres10"
  major_engine_version = "10.6"

  skip_final_snapshot = "true"
  deletion_protection = "false"
}

module "db_qa" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "eia-vip-reports-qa"

  engine            = "postgres"
  engine_version    = "10.6"
  instance_class    = "db.t3.medium"
  allocated_storage = 100
  storage_encrypted = false

  name     = "reports"
  username = "vip_reports_user"
  password = "vip_reports_pass"
  port     = "5432"

  vpc_security_group_ids = ["${module.sg_rds.this_security_group_id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = "${merge(local.amway_common_tags, local.data_tags, local.tags)}"

  subnet_ids = [
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_dev_a.id}",
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_dev_b.id}",
  ]

  family               = "postgres10"
  major_engine_version = "10.6"

  skip_final_snapshot = "true"
  deletion_protection = "false"
}

resource "aws_route53_record" "vip-report-qa" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "vip-report-qa.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${data.terraform_remote_state.kubernetes-cluster.ingress_endpoint_external}"
    zone_id                = "${data.terraform_remote_state.kubernetes-cluster.ingress_zone_external}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "vip-report-test" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "vip-report-test.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${data.terraform_remote_state.kubernetes-cluster.ingress_endpoint_external}"
    zone_id                = "${data.terraform_remote_state.kubernetes-cluster.ingress_zone_external}"
    evaluate_target_health = true
  }
}
