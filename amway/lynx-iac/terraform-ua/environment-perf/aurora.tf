resource "aws_rds_cluster" "perf" {
  cluster_identifier              = "${var.ec2_env_name}-db-cluster"
  engine                          = "aurora"
  engine_mode                     = "provisioned"
  engine_version                  = "${var.db_engine_version}"
  database_name                   = "perftest"
  master_username                 = "root"
  master_password                 = "${var.db_root_password}"
  final_snapshot_identifier       = "final-shapshot-${random_id.snapshot_identifier.hex}"
  deletion_protection             = "true"
  backup_retention_period         = "7"
  preferred_backup_window         = "${var.rds_preferred_backup_window}"
  preferred_maintenance_window    = "${var.rds_preferred_maintenance_window}"
  db_subnet_group_name            = "${aws_db_subnet_group.perf_db_group.name}"
  vpc_security_group_ids          = ["${aws_security_group.perf_sg.id}"]
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}

resource "aws_rds_cluster_instance" "perf" {
  count                           = "1"
  identifier                      = "${var.ec2_env_name}-db"
  cluster_identifier              = "${var.ec2_env_name}-db-cluster"
  engine                          = "aurora"
  engine_version                  = "${var.db_engine_version}"
  instance_class                  = "${var.rds_instance_class}"
  db_subnet_group_name            = "${aws_db_subnet_group.perf_db_group.name}"
  preferred_maintenance_window    = "${var.rds_preferred_maintenance_window}"
  monitoring_role_arn             = "${aws_iam_role.rds_enhanced_monitoring.arn}"
  monitoring_interval             = "${var.monitoring_interval}"
  auto_minor_version_upgrade      = "false"
  performance_insights_enabled    = "true"
  performance_insights_kms_key_id = "arn:aws:kms:eu-central-1:860702706577:key/7b0c7f54-cc97-4c22-be4c-5c764d6de5fa"

  depends_on = ["aws_rds_cluster.perf"]
}

resource "aws_db_subnet_group" "perf_db_group" {
  name       = "perf-db-group"
  subnet_ids = ["${data.terraform_remote_state.core.subnet.env_a.id}", "${data.terraform_remote_state.core.subnet.env_b.id}"]

  tags = {
    Name = "perf-db-group"
  }
}

resource "random_id" "snapshot_identifier" {
  keepers = {
    id = "${var.ec2_env_name}"
  }

  byte_length = 4
}

data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = "1"

  name               = "rds-enhanced-monitoring-perf"
  assume_role_policy = "${data.aws_iam_policy_document.monitoring_rds_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = "1"

  role       = "${aws_iam_role.rds_enhanced_monitoring.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
