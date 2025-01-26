locals {
  subnets_int = [
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_dev_a.id}",
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_dev_b.id}",
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_dev_c.id}",
  ]

  subnets_ext = [
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_public_a.id}",
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_public_b.id}",
    "${data.terraform_remote_state.core.subnet.virginia_dev.virginia_public_c.id}",
  ]

  ingress_target_group_int = "${
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

  ingress_target_group_ext = "${
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

  node_port_target_group_1 = "${
                    map(
                        "name", "${var.cluster_name}-node-port-1",
                        "backend_protocol", "TCP",
                        "backend_port", 30672,
                        "target_type", "instance",
                        "health_check_path", ""
                    )
                  }"

  node_port_listener_1 = "${
                map(
                    "port", 30672,
                    "protocol", "TCP",
                    "target_group_index", 1
                )
              }"

  node_port_target_group_2 = "${
                    map(
                        "name", "${var.cluster_name}-node-port-2",
                        "backend_protocol", "TCP",
                        "backend_port", 31672,
                        "target_type", "instance",
                        "health_check_path", ""
                    )
                  }"

  node_port_listener_2 = "${
                map(
                    "port", 31672,
                    "protocol", "TCP",
                    "target_group_index", 2
                )
              }"

  node_port_target_group_3 = "${
                    map(
                        "name", "${var.cluster_name}-node-port-3",
                        "backend_protocol", "TCP",
                        "backend_port", 31673,
                        "target_type", "instance",
                        "health_check_path", ""
                    )
                  }"

  node_port_listener_3 = "${
                map(
                    "port", 31673,
                    "protocol", "TCP",
                    "target_group_index", 3
                )
              }"

  node_port_target_group_4 = "${
                    map(
                        "name", "${var.cluster_name}-node-port-4",
                        "backend_protocol", "TCP",
                        "backend_port", 30673,
                        "target_type", "instance",
                        "health_check_path", ""
                    )
                  }"

  node_port_listener_4 = "${
                map(
                    "port", 30673,
                    "protocol", "TCP",
                    "target_group_index", 4
                )
              }"

  tags = "${map(
                   "Service", "${var.cluster_name}",
                   "Terraform", "true",
                   "Schedule", "running"
                  )}"
}
