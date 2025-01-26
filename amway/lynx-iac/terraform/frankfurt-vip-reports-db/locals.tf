locals {
  tags = "${map(
    "Service", "vip-reports",
    "Environment", "${terraform.workspace}",
    "Terraform", "true"
  )}"
}
