locals {
  tags = "${merge(var.tags, map("Terraform", "true", "ClusterName", var.cluster_name) )}"

  target_group = "${
                    map(
                        "name", "${var.cluster_name}-master-tg",
                        "backend_protocol", "TCP",
                        "backend_port", 6443,
                        "target_type", "instance",
                        "healthcheck_protocol", "TCP",
                        "health_check_port", 6443,
                        "health_check_path", ""
                    )
                  }"

  listener = "${
                map(
                    "port", 6443,
                    "protocol", "TCP",
                    "target_group_index", 0
                )
              }"
}
