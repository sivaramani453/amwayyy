data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "frankfurt-kubernetes-cluster" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "frankfurt-cluster.tfstate"
    region = "eu-central-1"
  }
}

module "internal-ingress-lb-mdms" {
  source = "../modules/aws-nlb"

  load_balancer_name        = "${var.microservice_name}-int-lb"
  load_balancer_is_internal = true

  vpc_id  = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  subnets = "${local.subnets}"

  target_groups_count = 1
  tcp_listeners_count = 1
  tcp_listeners       = ["${local.ingress_listener_amqp}"]
  target_groups       = ["${local.ingress_target_group_amqp}"]

  tags = "${local.tags}"
}

resource "aws_lb_target_group_attachment" "mdms-ru-amqp" {
  target_group_arn = "${module.internal-ingress-lb-mdms.aws_lb_target_group_arn[0]}"
  count            = "${length(local.instances)}"
  target_id        = "${element(local.instances, count.index)}"
}
