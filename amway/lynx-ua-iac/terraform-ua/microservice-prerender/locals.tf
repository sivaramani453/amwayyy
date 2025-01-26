locals {
  core_subnet_ids = ["${element("${data.terraform_remote_state.core.infra_subnets}",0)}","${element("${data.terraform_remote_state.core.infra_subnets}",1)}"]
  tags = "${map("Service", "${terraform.workspace}","Terraform", "true")}"
}

