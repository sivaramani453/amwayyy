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
  region            = "eu-central-1"
  create_route53    = true
  route53_zone_id   = "${data.terraform_remote_state.core.route53_zone_id}"
  route53_zone_name = "ru.eia.amway.net"
  vpc_id            = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  subnets           = "${local.subnets}"
  key_pair          = "${data.terraform_remote_state.core.frankfurt.ssh_key}"
  ami               = "ami-0c7602a9b3b11f555"
  s3_stage          = "prod-ru"
  s3_user_enabled   = "false"

  masters            = "${var.master_count}"
  master_shape       = "m5.large"
  master_volume_size = 100
  master_volume_iops = 2000

  workers            = "${var.worker_count}"
  worker_shape       = "m5.large"
  worker_volume_size = 50

  allow_ssh_from_subnets            = ["10.0.0.0/8"]
  allow_kube_api_subnets            = ["10.0.0.0/8"]
  allow_node_ports_subnets          = ["10.0.0.0/8"]
  allow_nginx_ingress_ports_subnets = ["10.0.0.0/8"]

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

resource "aws_security_group" "alb-sg" {
  name_prefix = "chartmuseum-alb"
  vpc_id      = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${module.kubernetes-cluster.workers_sg}"]
  }

  tags = "${local.tags}"
}

module "internal-ingress-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.6.0"

  load_balancer_name        = "${var.cluster_name}-ingress-int-alb"
  load_balancer_is_internal = "true"
  security_groups           = ["${aws_security_group.alb-sg.id}"]
  logging_enabled           = "false"
  subnets                   = "${local.alb_subnets}"
  vpc_id                    = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  https_listeners           = "${local.alb_listeners}"
  https_listeners_count     = "1"
  target_groups             = "${local.alb_target_groups}"
  target_groups_count       = "1"

  tags = "${local.tags}"
}

resource "aws_lb_target_group_attachment" "alb-internal-ingress" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.internal-ingress-alb.target_group_arns[0]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
  port             = 80
}

resource "aws_lb_target_group_attachment" "internal-ingress" {
  count            = "${var.worker_count}"
  target_group_arn = "${module.internal-ingress-lb.aws_lb_target_group_arn[0]}"
  target_id        = "${element(module.kubernetes-cluster.workers_instance_ids, count.index)}"
}

resource "aws_route53_record" "rancher" {
  zone_id = "${data.terraform_remote_state.core.route53_zone_id}"
  name    = "rancher.ru.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.internal-ingress-lb.dns_name}"
    zone_id                = "${module.internal-ingress-lb.zone_id}"
    evaluate_target_health = true
  }
}
