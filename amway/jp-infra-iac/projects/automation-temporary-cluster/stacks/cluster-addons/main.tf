module "aws_auth" {
  source         = "../../../../bases/eks-aws-auth"
  eks_auth_roles = var.eks_cluster_config.eks_auth_roles
}
