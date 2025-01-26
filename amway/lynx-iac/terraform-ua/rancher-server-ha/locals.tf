locals {
  subnets = [
    "${data.terraform_remote_state.core.subnet.core_a.id}",
    "${data.terraform_remote_state.core.subnet.core_b.id}",
    "${data.terraform_remote_state.core.subnet.core_c.id}",
  ]

  ingress_target_group = "${map(
                                "name", "${var.cluster_name}-internal-ingress",
                                "backend_protocol", "TCP",
                                "backend_port", 443,
                                "target_type", "instance",
                                "healthcheck_protocol", "HTTP",
                                "health_check_port", 80,
                                "health_check_path", "/healthz"
  )}"

  ingress_listener = "${map(
                    "port", 443,
                    "protocol", "TCP",
                    "target_group_index", 0
  )}"

  tags = "${map(
                   "Service", "${var.cluster_name}",
                   "Terraform", "true",
                   "Schedule", "running"
  )}"

  ingress_target_group_https = "${map("name", "${var.cluster_name}-ingress-https",
                   "backend_protocol", "HTTP",
                   "backend_port", "${var.rancher_node_port}",
                   "slow_start", 0
  )}"

  target_groups_defaults = "${map(
    "cookie_duration", 86400,
    "deregistration_delay", 300,
    "health_check_interval", 15,
    "health_check_healthy_threshold", 3,
    "health_check_path", "/health",
    "health_check_port", "traffic-port",
    "health_check_timeout", 10,
    "health_check_unhealthy_threshold", 3,
    "health_check_matcher", "200",
    "stickiness_enabled", "false",
    "target_type", "ip",
    "slow_start", 0
  )}"

  https_listeners = "${list(
                        map(
                            "certificate_arn", "arn:aws:acm:eu-central-1:860702706577:certificate/efae932f-a7bc-417f-bdd9-95c14f84699f",
                            "port", 443
                        )
  )}"
}
