locals {
  subnets = [
    "${data.terraform_remote_state.core.subnet.core_a.id}",
    "${data.terraform_remote_state.core.subnet.core_b.id}",
    "${data.terraform_remote_state.core.subnet.core_c.id}",
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

  ingress_listener = "${
                map(
                    "port", 443,
                    "protocol", "TCP",
                    "target_group_index", 0
                )
              }"

  node_port_target_group_1 = "${
                    map(
                        "name", "${var.cluster_name}-node-port-1",
                        "backend_protocol", "TCP",
                        "backend_port", 31692,
                        "target_type", "instance",
                        "health_check_path", ""
                    )
                  }"

  node_port_listener_1 = "${
                map(
                    "port", 31692,
                    "protocol", "TCP",
                    "target_group_index", 1
                )
              }"

  tags = "${map(
                   "Service", "${var.cluster_name}",
                   "Terraform", "true",
                   "Schedule", "running"
                  )}"
}
