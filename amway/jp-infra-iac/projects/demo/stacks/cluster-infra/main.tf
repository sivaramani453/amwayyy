module "demo_cluster" {
  source = "../../../../bases/generic-eks-cluster"

  eks_cluster_config = var.eks_cluster_config
  node_groups        = var.node_groups
  default_tags       = var.default_tags
  eks_extra_tags = {
    TerminationProtection = "false"
  }
  providers = {
    aws              = aws
    aws.oidc_creator = aws.oidc_creator
  }
}

output "common_infra_support_arn" {
  value = module.demo_cluster.common_infra_support_arn
}
