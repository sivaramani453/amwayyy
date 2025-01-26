data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "kubernetes-cluster" {
  source = "../modules/rke-cluster"

  cluster_name      = "${var.cluster_name}"
  region            = "eu-central-1"
  create_route53    = true
  route53_zone_id   = "${data.terraform_remote_state.core.route53_zone_id}"
  route53_zone_name = "ms.eia.amway.net"
  vpc_id            = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  subnets           = "${local.subnets}"
  key_pair          = "${data.terraform_remote_state.core.frankfurt.ssh_key}"
  ami               = "ami-07ee2abe53a42cd3f"
  s3_stage          = "prod"

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
  allow_node_ports_subnets          = ["0.0.0.0/0"]
  allow_nginx_ingress_ports_subnets = ["0.0.0.0/0"]

  tags = "${local.tags}"
}

module "internal-ingress-lb" {
  source = "../modules/aws-nlb"

  load_balancer_name        = "${var.cluster_name}-ingress-int"
  load_balancer_is_internal = true

  vpc_id  = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  subnets = "${local.subnets}"

  target_groups_count = 1
  tcp_listeners_count = 1
  tcp_listeners       = ["${local.ingress_listener}"]
  target_groups       = ["${local.ingress_target_group}"]

  tags = "${local.tags}"
}

module "external-ingress-lb" {
  source = "../modules/aws-nlb"

  load_balancer_name        = "${var.cluster_name}-ingress-ext"
  load_balancer_is_internal = false

  vpc_id  = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
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

resource "aws_lb_target_group_attachment" "external-ingress" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.external-ingress-lb.aws_lb_target_group_arn[0]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}
