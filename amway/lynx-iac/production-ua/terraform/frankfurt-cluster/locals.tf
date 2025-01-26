locals {
  subnets = [
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_c.id}",
  ]

  nat_subnets = [
    "${data.terraform_remote_state.core.frankfurt.subnet.public_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.public_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.public_c.id}",
  ]

  ingress_target_group = "${
                    map(
                        "name", "${var.cluster_name}-internal-ingress",
                        "backend_protocol", "TCP",
                        "backend_port", 443,
                        "target_type", "instance",
                        "healthcheck_protocol", "HTTP",
                        "health_check_port", 80,
                        "health_check_path", "/healthz"
                    )
                  }"

  external_ingress_target_group = "${
                    map(
                        "name", "${var.cluster_name}-external-ingress",
                        "backend_protocol", "TCP",
                        "backend_port", 443,
                        "target_type", "instance",
                        "healthcheck_protocol", "HTTP",
                        "health_check_port", 80,
                        "health_check_path", "/healthz"
                    )
                  }"

  ingress_listener = "${
                map(
                    "port", 443,
                    "protocol", "TCP",
                    "target_group_index", 0
                )
              }"

  tags = "${map(
                   "Service", "${var.cluster_name}",
                   "Terraform", "true"
                  )}"
}
