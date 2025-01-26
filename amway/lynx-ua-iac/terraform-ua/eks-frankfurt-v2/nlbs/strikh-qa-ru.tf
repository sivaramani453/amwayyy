locals {
  target_group_amqp_strikh_qa_ru = {
    "name"                 = "strikh-eks-v2-qa-ru-amqp"
    "backend_protocol"     = "TCP"
    "backend_port"         = 30676
    "target_type"          = "instance"
    "healthcheck_protocol" = "TCP"
    "health_check_port"    = 30676
    "health_check_path"    = ""
  }

  listener_amqp_strikh_qa_ru = {
    "name"               = "strikh-eks-v2-qa-ru-amqp"
    "port"               = 30676
    "protocol"           = "TCP"
    "target_group_index" = 0
  }

  target_group_http_strikh_qa_ru = {
    "name"                 = "strikh-eks-v2-qa-ru-http"
    "backend_protocol"     = "TCP"
    "backend_port"         = 31676
    "target_type"          = "instance"
    "healthcheck_protocol" = "HTTP"
    "health_check_port"    = 31676
    "health_check_path"    = "/"
  }

  listener_http_strikh_qa_ru = {
    "name"               = "strikh-eks-v2-qa-ru-http"
    "port"               = 31676
    "protocol"           = "TCP"
    "target_group_index" = 1
  }
}

module "nlb-strikh-qa-ru" {
  source = "../../modules/aws-nlb"

  load_balancer_name        = "strikh-eks-v2-qa-ru"
  load_balancer_is_internal = true

  vpc_id  = data.terraform_remote_state.eks-core.outputs.vpc_id
  subnets = data.terraform_remote_state.eks-core.outputs.private_subnets

  target_groups_count = 2
  tcp_listeners_count = 2
  tcp_listeners       = [local.listener_amqp_strikh_qa_ru, local.listener_http_strikh_qa_ru]
  target_groups       = [local.target_group_amqp_strikh_qa_ru, local.target_group_http_strikh_qa_ru]

  tags = {
    Cluster      = "eks-v2"
    Microservice = "strikh-qa-ru"
    Terraform    = "true"
  }
}

resource "aws_route53_record" "strikh-qa-ru" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "strikh-rabbitmq-qa-ru.mspreprod.eia.amway.net"
  type    = "A"

  alias {
    name                   = module.nlb-strikh-qa-ru.dns_name
    zone_id                = module.nlb-strikh-qa-ru.zone_id
    evaluate_target_health = "false"
  }
}

