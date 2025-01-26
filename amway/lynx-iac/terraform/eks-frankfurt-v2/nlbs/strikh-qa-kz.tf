locals {
  target_group_amqp_strikh_qa_kz = "${
                    map(
                        "name", "strikh-eks-v2-qa-kz-amqp",
                        "backend_protocol", "TCP",
                        "backend_port", 30677,
                        "target_type", "instance",
                        "healthcheck_protocol", "TCP",
                        "health_check_port", 30677,
                        "health_check_path", ""
                    )
                  }"

  listener_amqp_strikh_qa_kz = "${
                map(
                    "name", "strikh-eks-v2-qa-kz-amqp",
                    "port", 30677,
                    "protocol", "TCP",
                    "target_group_index", 0
                )
              }"

  target_group_http_strikh_qa_kz = "${
                    map(
                        "name", "strikh-eks-v2-qa-kz-http",
                        "backend_protocol", "TCP",
                        "backend_port", 31677,
                        "target_type", "instance",
                        "healthcheck_protocol", "HTTP",
                        "health_check_port", 31677,
                        "health_check_path", "/"
                    )
                  }"

  listener_http_strikh_qa_kz = "${
                map(
                    "name", "strikh-eks-v2-qa-kz-http",
                    "port", 31677,
                    "protocol", "TCP",
                    "target_group_index", 1
                )
              }"
}

module "nlb-strikh-qa-kz" {
  source = "../../modules/aws-nlb"

  load_balancer_name        = "strikh-eks-v2-qa-kz"
  load_balancer_is_internal = true

  vpc_id  = "${data.terraform_remote_state.eks-core.vpc_id}"
  subnets = "${data.terraform_remote_state.eks-core.private_subnets}"

  target_groups_count = 2
  tcp_listeners_count = 2
  tcp_listeners       = ["${local.listener_amqp_strikh_qa_kz}", "${local.listener_http_strikh_qa_kz}"]
  target_groups       = ["${local.target_group_amqp_strikh_qa_kz}", "${local.target_group_http_strikh_qa_kz}"]

  tags {
    Cluster      = "eks-v2"
    Microservice = "strikh-qa-kz"
    Terraform    = "true"
  }
}

resource "aws_route53_record" "strikh-qa-kz" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "strikh-rabbitmq-qa-kz.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.nlb-strikh-qa-kz.dns_name}"
    zone_id                = "${module.nlb-strikh-qa-kz.zone_id}"
    evaluate_target_health = "false"
  }
}
