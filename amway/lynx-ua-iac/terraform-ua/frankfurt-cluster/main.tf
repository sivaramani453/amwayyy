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
  region                 = "eu-central-1"
  create_route53         = true
  route53_zone_id        = "${data.terraform_remote_state.core.route53.zone.id}"
  route53_zone_name      = "hybris.eia.amway.net"
  vpc_id                 = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets                = "${local.subnets}"
  key_pair               = "EPAM-SE"
  ami                    = "ami-0c56235ac899a5f8b"
  s3_stage               = "test"
  masters                = "${var.master_count}"
  master_shape           = "t3.large"
  master_volume_size     = 100
  workers                = "${var.worker_count}"
  worker_shape           = "t3.large"
  worker_volume_size     = 200
  allow_ssh_from_subnets = ["10.0.0.0/8"]
  allow_kube_api_subnets = ["10.0.0.0/8"]

  # should be limited to tighter ranges
  allow_node_ports_subnets          = ["10.0.0.0/8", "172.16.0.0/12"]
  allow_nginx_ingress_ports_subnets = ["10.0.0.0/8", "172.16.0.0/12"]
  tags                              = "${local.tags}"
}

module "internal-ingress-lb" {
  source = "../modules/aws-nlb"

  load_balancer_name        = "${var.cluster_name}-ingress-int"
  load_balancer_is_internal = true

  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = "${local.subnets}"

  target_groups_count = 2
  tcp_listeners_count = 2
  tcp_listeners       = ["${local.ingress_listener}", "${local.node_port_listener_1}"]
  target_groups       = ["${local.ingress_target_group}", "${local.node_port_target_group_1}"]

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
