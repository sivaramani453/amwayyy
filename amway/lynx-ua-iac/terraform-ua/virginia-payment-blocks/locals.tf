locals {
  tags = "${map(
    "Service", "payment-blocks",
    "Environment", "dev",
    "Terraform", "true"
  )}"
}
