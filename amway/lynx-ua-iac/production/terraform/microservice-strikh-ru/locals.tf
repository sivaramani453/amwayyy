locals {
  subnets = [
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_c.id}",
  ]

  instances = ["${data.terraform_remote_state.frankfurt-kubernetes-cluster.workers_private_ids}"]

  ingress_target_group_amqp = "${
                    map(
                        "name", "${var.microservice_name}-amqp",
                        "backend_protocol", "TCP",
                        "backend_port", 30682,
                        "target_type", "instance",
                        "healthcheck_protocol", "TCP",
                        "health_check_port", 30682,
                        "health_check_path", ""
                    )
                  }"

  ingress_listener-amqp = "${
                map(
                    "name", "${var.microservice_name}-amqp",
                    "port", 30682,
                    "protocol", "TCP",
                    "target_group_index", 0
                )
              }"

  ingress_target_group_http = "${
                    map(
                        "name", "${var.microservice_name}-http",
                        "backend_protocol", "TCP",
                        "backend_port", 31682,
                        "target_type", "instance",
                        "healthcheck_protocol", "HTTP",
                        "health_check_port", 31682,
                        "health_check_path", "/"
                    )
                  }"

  ingress_listener-http = "${
                map(
                    "name", "${var.microservice_name}-http",
                    "port", 31682,
                    "protocol", "TCP",
                    "target_group_index", 1
                )
              }"

  tags = "${map(
                   "Service", "${var.microservice_name}",
                   "Terraform", "true"
                  )}"
}
