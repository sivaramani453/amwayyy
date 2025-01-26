locals {
  kube_subnet_ids = [
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_c.id}",
  ]

  kube_subnet_cidrs = [
    "${data.aws_subnet.kube-a.cidr_block}",
    "${data.aws_subnet.kube-b.cidr_block}",
    "${data.aws_subnet.kube-c.cidr_block}",
  ]

  nat_subnets = [
    "${data.terraform_remote_state.core.frankfurt.subnet.public_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.public_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.public_c.id}",
  ]

  instances = ["${data.terraform_remote_state.frankfurt-kubernetes-cluster.workers_private_ids}"]

  health_check = {
    interval            = 10
    port                = "traffic-port"
    protocol            = "TCP"
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags = "${map(
                   "Service", "${terraform.workspace}",
                   "Terraform", "true"
                  )}"
}
