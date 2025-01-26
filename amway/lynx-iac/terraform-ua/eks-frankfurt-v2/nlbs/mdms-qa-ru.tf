locals {
  target_group_http_mdms_qa_ru = "${
                    map(
                        "name", "mdms-eks-v2-qa-ru-http",
                        "backend_protocol", "TCP",
                        "backend_port", 31684,
                        "target_type", "instance",
                        "healthcheck_protocol", "HTTP",
                        "health_check_port", 31684,
                        "health_check_path", "/"
                    )
                  }"

  listener_http_mdms_qa_ru = "${
                map(
                    "name", "mdms-eks-v2-qa-ru-http",
                    "port", 80,
                    "protocol", "TCP",
                    "target_group_index", 0
                )
              }"
}

module "nlb-mdms-qa-ru" {
  source = "../../modules/aws-nlb"

  load_balancer_name        = "mdms-eks-v2-qa-ru"
  load_balancer_is_internal = true

  vpc_id  = "${data.terraform_remote_state.eks-core.vpc_id}"
  subnets = "${data.terraform_remote_state.eks-core.private_subnets}"

  target_groups_count = 1
  tcp_listeners_count = 1
  tcp_listeners       = ["${local.listener_http_mdms_qa_ru}"]
  target_groups       = ["${local.target_group_http_mdms_qa_ru}"]

  tags {
    Cluster      = "eks-v2"
    Microservice = "mdms-qa-ru"
    Terraform    = "true"
  }
}

resource "aws_route53_record" "mdms-qa-ru" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "rabbitmq-mgmt-ru-qa.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.nlb-mdms-qa-ru.dns_name}"
    zone_id                = "${module.nlb-mdms-qa-ru.zone_id}"
    evaluate_target_health = "false"
  }
}
