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

module "internal-ingress-lb-strikh" {
  source = "../modules/aws-nlb"

  load_balancer_name        = "${var.microservice_name}-lb"
  load_balancer_is_internal = true

  vpc_id  = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  subnets = "${local.subnets}"

  target_groups_count = 2
  tcp_listeners_count = 2
  tcp_listeners       = ["${local.ingress_listener-amqp}", "${local.ingress_listener-http}"]
  target_groups       = ["${local.ingress_target_group_amqp}", "${local.ingress_target_group_http}"]

  tags = "${local.tags}"
}

resource "aws_lb_target_group_attachment" "strikh-kz-http" {
  target_group_arn = "${module.internal-ingress-lb-strikh.aws_lb_target_group_arn[0]}"
  count            = "${length(local.instances)}"
  target_id        = "${element(local.instances, count.index)}"
}

resource "aws_lb_target_group_attachment" "strikh-kz-amqp" {
  target_group_arn = "${module.internal-ingress-lb-strikh.aws_lb_target_group_arn[1]}"
  count            = "${length(local.instances)}"
  target_id        = "${element(local.instances, count.index)}"
}
