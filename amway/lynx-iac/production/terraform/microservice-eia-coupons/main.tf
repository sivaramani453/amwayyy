data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_subnet" "kube-a" {
  id = "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_a.id}"
}

data "aws_subnet" "kube-b" {
  id = "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_b.id}"
}

data "aws_subnet" "kube-c" {
  id = "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_c.id}"
}

resource "aws_security_group" "db" {
  name   = "prod-eia-coupons-db"
  vpc_id = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "${data.aws_subnet.kube-a.cidr_block}", "${data.aws_subnet.kube-b.cidr_block}", "${data.aws_subnet.kube-c.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "1.31.0"

  identifier = "prod-eia-coupons-db"

  engine                     = "postgres"
  engine_version             = "10.4"
  family                     = "postgres10"
  major_engine_version       = "10"
  instance_class             = "db.m5.xlarge"
  allocated_storage          = 100
  max_allocated_storage      = 150
  auto_minor_version_upgrade = false

  username = "root"
  password = "${var.root_password}"
  port     = "5432"

  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  multi_az               = true
  create_db_subnet_group = false
  db_subnet_group_name   = "${data.terraform_remote_state.core.frankfurt.subnet.rds_group}"

  apply_immediately = false

  # UTC timezone
  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 8

  performance_insights_enabled = true

  deletion_protection = true

  tags = {
    Terraform = "true"
  }
}
