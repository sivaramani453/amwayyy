data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-ru-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "frankfurt-kubernetes-cluster" {
  backend = "s3"

  config {
    bucket = "prod-ru-amway-terraform-states"
    key    = "frankfurt-cluster.tfstate"
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

resource "aws_elasticache_subnet_group" "redis_cluster_sng" {
  name       = "redis-cluster-${terraform.workspace}"
  subnet_ids = ["${local.kube_subnet_ids}"]
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
    num_node_groups         = 3
  }

  tags = "${local.tags}"
}

module "redis_cluster_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "${terraform.workspace}-redis-cluster-sg"
  description = "Security group for Redis Cluster"
  vpc_id      = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"

  ingress_cidr_blocks = ["${local.kube_subnet_cidrs}"]
  ingress_rules       = ["redis-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_lb" "prerender_ext_lb" {
  name                       = "${terraform.workspace}-ext-lb"
  internal                   = false
  load_balancer_type         = "network"
  subnets                    = ["${local.nat_subnets}"]
  enable_deletion_protection = false
  idle_timeout               = 120

  tags = "${local.tags}"
}

resource "aws_lb_listener" "prerender_ext_lb_listner" {
  load_balancer_arn = "${aws_lb.prerender_ext_lb.arn}"
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:eu-central-1:645993801158:certificate/cfb2dc26-b0d5-4729-b6cb-96303c3f10f3"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.prerender_tg.arn}"
  }
}

resource "aws_lb_target_group" "prerender_tg" {
  name                 = "${terraform.workspace}-tg"
  port                 = "31280"
  protocol             = "TCP"
  vpc_id               = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  target_type          = "instance"
  deregistration_delay = 300
  slow_start           = 0

  health_check = ["${local.health_check}"]

  tags = "${local.tags}"
}

resource "aws_lb_target_group_attachment" "prerender_tg_attachment" {
  target_group_arn = "${aws_lb_target_group.prerender_tg.arn}"
  count            = "${length(local.instances)}"
  target_id        = "${element(local.instances, count.index)}"
}
