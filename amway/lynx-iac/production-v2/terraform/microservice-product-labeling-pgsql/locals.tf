locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  kube_subnet_cidrs = [
    "${data.aws_subnet.kube-a.cidr_block}",
    "${data.aws_subnet.kube-b.cidr_block}",
    "${data.aws_subnet.kube-c.cidr_block}",
  ]

  kube_subnet_ids = [
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_c.id}",
  ]

  amway_common_tags = "${map(
         "Terraform", "True",
         "Evironment", "PROD",
         "ApplicationID", "${terraform.workspace}"
 )}"

  amway_ec2_specific_tags = "${map(
     "DataClassification", "EC2",
     "SEC-INFRA-13", "Null",
     "SEC-INFRA-14", "Null"  
 )}"

  amway_ebs_specific_tags = "${map(
    "DataClassification", "EBS"
  )}"

  amway_efs_specific_tags = "${map(
    "DataClassification", "EFS"

  )}"
}
