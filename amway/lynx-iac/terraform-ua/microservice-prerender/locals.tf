locals {
  core_subnet_ids = [
    "${data.terraform_remote_state.core.subnet.core_a.id}",
    "${data.terraform_remote_state.core.subnet.core_b.id}",
  ]

  tags = "${map(
                   "Service", "${terraform.workspace}",
                   "Terraform", "true"
                  )}"
}
