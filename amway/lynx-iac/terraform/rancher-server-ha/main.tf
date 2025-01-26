data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "kubernetes-cluster" {
  source = "../modules/rke-cluster/"

  cluster_name                      = "${var.cluster_name}"
  region                            = "eu-central-1"
  create_route53                    = true
  route53_zone_id                   = "${data.terraform_remote_state.core.route53.zone.id}"
  route53_zone_name                 = "hybris.eia.amway.net"
  vpc_id                            = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets                           = "${local.subnets}"
  key_pair                          = "EPAM-SE"
  ami                               = "ami-0c56235ac899a5f8b"
  s3_stage                          = "test"
  masters                           = "${var.master_count}"
  master_shape                      = "t3.large"
  master_volume_size                = 100
  workers                           = "${var.worker_count}"
  worker_shape                      = "t3.large"
  worker_volume_size                = 50
  allow_ssh_from_subnets            = ["10.0.0.0/8"]
  allow_kube_api_subnets            = ["10.0.0.0/8"]
  allow_node_ports_subnets          = ["10.0.0.0/8"]
  allow_nginx_ingress_ports_subnets = ["10.0.0.0/8", "192.168.0.0/22"]
  tags                              = "${local.tags}"
}

module "internal-ingress-lb" {
  source = "../modules/aws-nlb/"

  load_balancer_name        = "${var.cluster_name}-ingress-int"
  load_balancer_is_internal = true

  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = "${local.subnets}"

  target_groups_count = 1
  tcp_listeners_count = 1
  tcp_listeners       = ["${local.ingress_listener}"]
  target_groups       = ["${local.ingress_target_group}"]

  tags = "${local.tags}"
}

resource "aws_lb_target_group_attachment" "internal-ingress" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.internal-ingress-lb.aws_lb_target_group_arn[0]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}

resource "aws_route53_record" "rancher" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "rancher.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.alb.dns_name}"
    zone_id                = "${module.alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}
