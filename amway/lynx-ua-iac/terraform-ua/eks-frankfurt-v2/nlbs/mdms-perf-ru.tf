locals {
  target_group_http_mdms_perf_ru = {
    "name"                 = "mdms-eks-v2-perf-ru-http"
    "backend_protocol"     = "TCP"
    "backend_port"         = 31688
    "target_type"          = "instance"
    "healthcheck_protocol" = "HTTP"
    "health_check_port"    = 31688
    "health_check_path"    = "/"
  }

  listener_http_mdms_perf_ru = {
    "name"               = "mdms-eks-v2-perf-ru-http"
    "port"               = 80
    "protocol"           = "TCP"
    "target_group_index" = 0
  }
}

module "nlb-mdms-perf-ru" {
  source = "../../modules/aws-nlb"

  load_balancer_name        = "mdms-eks-v2-perf-ru"
  load_balancer_is_internal = true

  vpc_id  = data.terraform_remote_state.eks-core.outputs.vpc_id
  subnets = data.terraform_remote_state.eks-core.outputs.private_subnets

  target_groups_count = 1
  tcp_listeners_count = 1
  tcp_listeners       = [local.listener_http_mdms_perf_ru]
  target_groups       = [local.target_group_http_mdms_perf_ru]

  tags = {
    Cluster      = "eks-v2"
    Microservice = "mdms-perf-ru"
    Terraform    = "true"
  }
}

resource "aws_route53_record" "mdms-perf-ru" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "rabbitmq-mgmt-ru-perf.mspreprod.eia.amway.net"
  type    = "A"

  alias {
    name                   = module.nlb-mdms-perf-ru.dns_name
    zone_id                = module.nlb-mdms-perf-ru.zone_id
    evaluate_target_health = "false"
  }
}

