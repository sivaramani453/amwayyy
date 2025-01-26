module "aws_auth" {
  source         = "../../../../bases/eks-aws-auth"
  eks_auth_roles = var.eks_cluster_config.eks_auth_roles
}

module "common_addons" {
  source                   = "../../../../bases/common-addons"
  common_infra_support_arn = var.common_infra_support_arn
  eks_cluster_config       = var.eks_cluster_config
  domain_info              = var.domain_info
  jaeger                   = var.jaeger
  splunk_token             = var.splunk_token
  komodor_api_key          = var.komodor_api_key
  jaeger_dns_info          = var.jaeger_dns_info
  loki                     = var.loki
  prometheus               = var.prometheus
}

module "automation_addons" {
  source                   = "../../../../bases/automation-addons"
  argocd                   = var.argocd
  common_infra_support_arn = var.common_infra_support_arn
}
