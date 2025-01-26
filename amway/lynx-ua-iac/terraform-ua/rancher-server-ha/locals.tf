locals {
  subnets = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_ec2_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_ec2_b_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_ec2_c_id,
  ]

  ingress_target_group = {
    "name"                 = "${var.cluster_name}-internal-ingress"
    "backend_protocol"     = "TCP"
    "backend_port"         = 443
    "target_type"          = "instance"
    "healthcheck_protocol" = "HTTP"
    "health_check_port"    = 80
    "health_check_path"    = "/healthz"
  }

  ingress_listener = {
    "port"               = 443
    "protocol"           = "TCP"
    "target_group_index" = 0
  }

  tags = {
    "Service"   = var.cluster_name
    "Terraform" = "true"
    "Schedule"  = "running"
  }

  ingress_target_group_https = {
    "name"             = "${var.cluster_name}-ingress-https"
    "backend_protocol" = "HTTP"
    "backend_port"     = var.rancher_node_port
    "slow_start"       = 0
  }

  target_groups_defaults = {
    "cookie_duration"                  = 86400
    "deregistration_delay"             = 300
    "health_check_interval"            = 15
    "health_check_healthy_threshold"   = 3
    "health_check_path"                = "/health"
    "health_check_port"                = "traffic-port"
    "health_check_timeout"             = 10
    "health_check_unhealthy_threshold" = 3
    "health_check_matcher"             = "200"
    "stickiness_enabled"               = "false"
    "target_type"                      = "ip"
    "slow_start"                       = 0
  }

  https_listeners = [
    {
      "certificate_arn" = "arn:aws:acm:eu-central-1:728244295542:certificate/240f53e3-94fb-44ec-b30c-a356f49e5668"
      "port"            = 443
    },
  ]
}

