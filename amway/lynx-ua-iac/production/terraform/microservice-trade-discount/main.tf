data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_subnet" "kube-a" {
  id = "${data.terraform_remote_state.core.mumbai.subnet.kubenetes_a.id}"
}

data "aws_subnet" "kube-b" {
  id = "${data.terraform_remote_state.core.mumbai.subnet.kubenetes_b.id}"
}

data "aws_subnet" "kube-c" {
  id = "${data.terraform_remote_state.core.mumbai.subnet.kubenetes_c.id}"
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "trade-discount-db-sg"
  description = "Security group for TradeDiscount database"
  vpc_id      = "${data.terraform_remote_state.core.mumbai.prod_vpc.id}"

  ingress_cidr_blocks = ["${data.aws_subnet.kube-a.cidr_block}", "${data.aws_subnet.kube-b.cidr_block}", "${data.aws_subnet.kube-c.cidr_block}"]
  ingress_rules       = ["mysql-tcp"]

  egress_rules = ["all-all"]
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "1.31.0"

  identifier = "trade-discount-db"

  engine                     = "mysql"
  engine_version             = "5.6.44"
  family                     = "mysql5.6"
  major_engine_version       = "5.6"
  instance_class             = "db.r4.large"
  allocated_storage          = 500
  max_allocated_storage      = 1000
  auto_minor_version_upgrade = false

  username = "root"
  password = "${var.root_password}"
  port     = "3306"

  vpc_security_group_ids = ["${module.db_security_group.this_security_group_id}"]
  multi_az               = true
  create_db_subnet_group = false
  db_subnet_group_name   = "${data.terraform_remote_state.core.mumbai.subnet.rds_group}"

  apply_immediately = true

  # UTC timezone
  maintenance_window      = "Mon:18:30-Mon:19:30"
  backup_window           = "20:30-21:30"
  backup_retention_period = 8

  performance_insights_enabled = true

  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "latin1"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    },
    {
      name  = "time_zone"
      value = "Asia/Calcutta"
    },
  ]

  tags = {
    Terraform = "true"
    Service   = "trade-discount"
  }
}
