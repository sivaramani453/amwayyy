locals {
  subnets = [
    "${data.terraform_remote_state.core.frankfurt.subnet.rancher_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.rancher_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.rancher_c.id}",
  ]

  alb_subnets = [
    "${data.terraform_remote_state.core.frankfurt.subnet.rancher_alb_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.rancher_alb_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.rancher_alb_c.id}",
  ]

  alb_target_groups = "${list(
                              map(
                                  "name", "${var.cluster_name}-ingress-alb",
                                  "backend_protocol", "HTTP",
                                  "backend_port", 80,
                                  "health_check_timeout", 3,
                                  "health_check_interval", 5,
                                  "health_check_path", "/healthz"
                              )
  )}"

  alb_listeners = "${list(
                          map(
                              "certificate_arn", "${data.terraform_remote_state.core.frankfurt.certificate_arn}",
                              "port", 443
                          )
  )}"

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
                   "Terraform", "true"
  )}"
}
