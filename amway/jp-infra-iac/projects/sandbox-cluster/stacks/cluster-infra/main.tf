module "automation_cluster" {
  source = "../../../../bases/generic-eks-cluster"

  eks_cluster_config = var.eks_cluster_config
  node_groups        = var.node_groups
  default_tags       = var.default_tags
  providers = {
    aws              = aws
    aws.oidc_creator = aws.oidc_creator
  }
}
