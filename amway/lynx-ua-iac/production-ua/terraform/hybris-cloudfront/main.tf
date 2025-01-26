#data "terraform_remote_state" "core" {
#  backend = "s3"
#  config = {
#    bucket = "amway-terraform-states"
#    key    = "core2/terraform.tfstate"
#    region = "eu-central-1"
#  }
#}

locals {
  amway_tags = tomap({
         "Terraform" = "True",
         "Evironment" = var.waf_enabled ? "DEV" : "PROD",
         "DataClassification" = "Internal",
         "ApplicationID" = "APP3150571"})
         
#  route53_zone = var.waf_enabled ? "Z01793602SX7SQ8XPUE1A" : "ZNTYJYCMRBH4S"

# cf_list = "${split("-", terraform.workspace)}"
# cloudfront_domain = "${format("%s-%s-%s",local.cf_list[0],local.cf_list[1],local.cf_list[3])}"
}
