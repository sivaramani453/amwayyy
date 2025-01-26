### This remote state allows us to reuse some info from another stack
data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket         = "jpn-automation-dev-tfstate"
    key            = "demo-infra"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"

  }
}

## Get the output we defined in the infra stack
locals {
  common_infra_support_arn = data.terraform_remote_state.infra.outputs.common_infra_support_arn
}

module "common_addons" {
  source                   = "../../../../bases/common-addons"
  common_infra_support_arn = local.common_infra_support_arn
  eks_cluster_config       = var.eks_cluster_config
  domain_info              = var.domain_info
}
