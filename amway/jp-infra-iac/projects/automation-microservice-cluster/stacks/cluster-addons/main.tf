module "aws_auth" {
  source         = "../../../../bases/eks-aws-auth"
  eks_auth_roles = var.eks_cluster_config.eks_auth_roles
}

module "automation_addons" {
  source                   = "../../../../bases/automation-addons"
  argocd                   = var.argocd
  arc_github_token         = var.github_token
  common_infra_support_arn = var.common_infra_support_arn
}

module "common-addons" {
  source                   = "../../../../bases/common-addons"
  common_infra_support_arn = var.common_infra_support_arn
  eks_cluster_config       = var.eks_cluster_config
  domain_info              = var.domain_info
}

module "microservice-addons" {
  source                   = "../../../../bases/microservice-addons"
  common_infra_support_arn = var.common_infra_support_arn
  eks_cluster_config       = var.eks_cluster_config
  domain_info              = var.domain_info
  jaeger                   = var.jaeger
  loki                     = var.loki
  prometheus               = var.prometheus
}
