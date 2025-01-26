data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "kubernetes-cluster" {
  source = "../modules/rke-cluster"

  cluster_name           = "${var.cluster_name}"
  region                 = "us-east-1"
  create_route53         = true
  route53_zone_id        = "${data.terraform_remote_state.core.route53.zone.id}"
  route53_zone_name      = "hybris.eia.amway.net"
  vpc_id                 = "${data.terraform_remote_state.core.vpc.virginia_dev.id}"
  subnets                = "${local.subnets_int}"
  key_pair               = "ansible_rsa.pem"
  ami                    = "ami-0a448acf9e5b16b63"
  s3_stage               = "test"
  masters                = "${var.master_count}"
  master_shape           = "t3.large"
  master_volume_size     = 100
  workers                = "${var.worker_count}"
  worker_shape           = "t3.large"
  worker_volume_size     = 50
  allow_ssh_from_subnets = ["10.0.0.0/8"]
  allow_kube_api_subnets = ["10.0.0.0/8"]

  # should be limited to tighter ranges
  allow_node_ports_subnets          = ["10.0.0.0/8", "172.16.0.0/12"]
  allow_nginx_ingress_ports_subnets = ["10.0.0.0/8", "172.16.0.0/12", "0.0.0.0/0"]
  tags                              = "${merge(local.amway_common_tags, local.instance_tags, local.tags)}"
}

module "internal-ingress-lb" {
  source = "../modules/aws-nlb"

  load_balancer_name        = "${var.cluster_name}-ingress-int"
  load_balancer_is_internal = true

  vpc_id  = "${data.terraform_remote_state.core.vpc.virginia_dev.id}"
  subnets = "${local.subnets_int}"

  target_groups_count = 5
  tcp_listeners_count = 5
  tcp_listeners       = ["${local.ingress_listener}", "${local.node_port_listener_1}", "${local.node_port_listener_2}", "${local.node_port_listener_3}", "${local.node_port_listener_4}"]
  target_groups       = ["${local.ingress_target_group_int}", "${local.node_port_target_group_1}", "${local.node_port_target_group_2}", "${local.node_port_target_group_3}", "${local.node_port_target_group_4}"]

  tags = "${merge(local.amway_common_tags, local.tags)}"
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

resource "aws_lb_target_group_attachment" "internal-node-port-3" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.internal-ingress-lb.aws_lb_target_group_arn[3]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}

resource "aws_lb_target_group_attachment" "internal-node-port-4" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.internal-ingress-lb.aws_lb_target_group_arn[4]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}

module "external-ingress-lb" {
  source = "../modules/aws-nlb"

  load_balancer_name        = "${var.cluster_name}-ingress-ext"
  load_balancer_is_internal = false

  vpc_id  = "${data.terraform_remote_state.core.vpc.virginia_dev.id}"
  subnets = "${local.subnets_ext}"

  target_groups_count = 1
  tcp_listeners_count = 1
  tcp_listeners       = ["${local.ingress_listener}"]
  target_groups       = ["${local.ingress_target_group_ext}"]

  tags = "${merge(local.amway_common_tags, local.tags)}"
}

resource "aws_lb_target_group_attachment" "external-ingress" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.external-ingress-lb.aws_lb_target_group_arn[0]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}
