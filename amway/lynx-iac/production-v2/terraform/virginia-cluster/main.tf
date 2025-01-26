data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-ru-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "kubernetes-cluster" {
  source = "../modules/rke-cluster"

  cluster_name      = "${var.cluster_name}"
  region            = "us-east-1"
  create_route53    = true
  route53_zone_id   = "${data.terraform_remote_state.core.route53_zone_id}"
  route53_zone_name = "ru.eia.amway.net"
  vpc_id            = "${data.terraform_remote_state.core.virginia.prod_vpc.id}"
  subnets           = "${local.subnets}"
  key_pair          = "${data.terraform_remote_state.core.virginia.ssh_key}"
  ami               = "ami-03cf06a3f352e5dcc"
  s3_stage          = "prod-ru"
  s3_user_enabled   = "false"

  masters            = "${var.master_count}"
  master_shape       = "m5.xlarge"
  master_volume_size = 100
  master_volume_iops = 1000

  workers            = "${var.worker_count}"
  worker_shape       = "m5.xlarge"
  worker_volume_size = 200

  allow_ssh_from_subnets = ["10.0.0.0/8"]
  allow_kube_api_subnets = ["10.0.0.0/8"]

  # should be limited to tighter ranges
  allow_node_ports_subnets          = ["10.0.0.0/8", "172.16.0.0/12"]
  allow_nginx_ingress_ports_subnets = ["0.0.0.0/0"]

  tags = "${local.tags}"
}

resource "aws_security_group" "db" {
  name   = "${var.cluster_name}-db"
  vpc_id = "${data.terraform_remote_state.core.virginia.prod_vpc.id}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "TCP"
    security_groups = ["${module.kubernetes-cluster.workers_sg}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${local.tags}"
}

module "internal-ingress-lb" {
  source = "../modules/aws-nlb"

  load_balancer_name        = "${var.cluster_name}-ingress-int"
  load_balancer_is_internal = true

  vpc_id  = "${data.terraform_remote_state.core.virginia.prod_vpc.id}"
  subnets = "${local.subnets}"

  target_groups_count = 3
  tcp_listeners_count = 3
  tcp_listeners       = ["${local.ingress_listener}", "${local.node_port_listener_1}", "${local.node_port_listener_2}"]
  target_groups       = ["${local.ingress_target_group}", "${local.node_port_target_group_1}", "${local.node_port_target_group_2}"]

  tags = "${local.tags}"
}

module "external-ingress-lb" {
  source = "../modules/aws-nlb"

  load_balancer_name        = "${var.cluster_name}-ingress-ext"
  load_balancer_is_internal = false

  vpc_id  = "${data.terraform_remote_state.core.virginia.prod_vpc.id}"
  subnets = "${local.nat_subnets}"

  target_groups_count = 1
  tcp_listeners_count = 1
  tcp_listeners       = ["${local.ingress_listener}"]
  target_groups       = ["${local.external_ingress_target_group}"]

  tags = "${local.tags}"
}

resource "aws_lb_target_group_attachment" "internal-ingress" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.internal-ingress-lb.aws_lb_target_group_arn[0]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}

resource "aws_lb_target_group_attachment" "internal-node-port-1" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.internal-ingress-lb.aws_lb_target_group_arn[1]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}

resource "aws_lb_target_group_attachment" "internal-node-port-2" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.internal-ingress-lb.aws_lb_target_group_arn[2]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}

resource "aws_lb_target_group_attachment" "external-ingress" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.external-ingress-lb.aws_lb_target_group_arn[0]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}
