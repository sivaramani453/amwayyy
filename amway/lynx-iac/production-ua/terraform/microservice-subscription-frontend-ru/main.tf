data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-ru-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]

  amway_tags = "${map(
         "Terraform", "True",
         "Evironment", "PROD",
         "DataClassification", "Internal",
         "ApplicationID", "APP3150571"
 )}"

# cf_list = "${split("-", terraform.workspace)}"
# cloudfront_domain = "${format("%s-%s-%s",local.cf_list[0],local.cf_list[1],local.cf_list[3])}"
  cloudfront_domain = "${var.alb_domain}"
}
