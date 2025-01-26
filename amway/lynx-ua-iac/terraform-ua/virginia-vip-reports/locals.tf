locals {
  tags = "${map(
    "Service", "vip-reports",
    "Environment", "dev",
    "Terraform", "true"
  )}"
}
