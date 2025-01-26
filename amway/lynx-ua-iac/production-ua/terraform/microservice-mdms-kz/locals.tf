locals {
  subnets = [
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_c.id}",
  ]

  instances = ["${data.terraform_remote_state.frankfurt-kubernetes-cluster.workers_private_ids}"]

  ingress_target_group_amqp = "${
                    map(
                        "name", "${var.microservice_name}-amqp-internal",
                        "backend_protocol", "TCP",
                        "backend_port", 31691,
                        "target_type", "instance",
                        "healthcheck_protocol", "TCP",
                        "health_check_port", 31691,
                        "health_check_path", ""
                    )
                  }"

  ingress_listener_amqp = "${
                map(
                    "name", "${var.microservice_name}-amqp",
                    "port", 31691,
                    "protocol", "TCP",
                    "target_group_index", 0
                )
              }"

  tags = "${map(
                   "Service", "${var.microservice_name}",
                   "Terraform", "true"
                  )}"
}
