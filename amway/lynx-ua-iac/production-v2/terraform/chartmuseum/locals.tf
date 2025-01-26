locals {
  tags = "${map(
                "Service", "chartmuseum",
                "Terraform", "true"
          )}"
}
