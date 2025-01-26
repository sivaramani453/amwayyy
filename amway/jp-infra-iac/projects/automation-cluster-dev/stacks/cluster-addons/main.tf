data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket         = "jpn-automation-dev-tfstate"
    key            = "automation-cluster-dev-infra"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"

  }
}

locals {
  common_infra_support_arn = data.terraform_remote_state.infra.outputs.common_infra_support_arn
}

module "common_addons" {
  source                   = "../../../../bases/common-addons"
  common_infra_support_arn = local.common_infra_support_arn
  eks_cluster_config       = var.eks_cluster_config
  domain_info              = var.domain_info
}

module "automation_addons" {
  source = "../../../../bases/automation-addons"

  github_auth       = var.github_auth
  github_config_url = var.github_config_url

  common_infra_support_arn = local.common_infra_support_arn
  argocd                   = var.argocd

  runner_name = "jpn-automation-dev"
}
