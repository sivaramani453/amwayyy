data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_elasticache_subnet_group" "redis_cluster_sng" {
  name       = "redis-cluster-${terraform.workspace}"
  subnet_ids = ["${local.core_subnet_ids}"]
}

resource "aws_elasticache_parameter_group" "redis_cluster_pg" {
  name   = "redis-cluster-${terraform.workspace}"
  family = "redis5.0"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}

resource "aws_elasticache_replication_group" "redis_cluster" {
  replication_group_id          = "redis-cluster-${terraform.workspace}"
  replication_group_description = "Redis cluster for Prerender Microservice"

  engine_version             = "5.0.6"
  node_type                  = "cache.t3.medium"
  port                       = 6379
  auto_minor_version_upgrade = "false"
  maintenance_window         = "mon:22:30-mon:23:30"
  parameter_group_name       = "${aws_elasticache_parameter_group.redis_cluster_pg.name}"

  security_group_ids         = ["${module.redis_cluster_sg.this_security_group_id}"]
  subnet_group_name          = "${aws_elasticache_subnet_group.redis_cluster_sng.name}"
  automatic_failover_enabled = "true"

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 2
  }

  tags = "${local.tags}"
}

module "redis_cluster_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "${terraform.workspace}-redis-cluster-sg"
  description = "Security group for Redis Cluster"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]
  ingress_rules       = ["redis-tcp"]
  egress_rules        = ["all-all"]
}
