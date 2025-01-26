module "automation_cluster" {
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

output "ClusterInfo" {
  value = {
    oidc = module.automation_cluster.eks_cluster
  }
}
