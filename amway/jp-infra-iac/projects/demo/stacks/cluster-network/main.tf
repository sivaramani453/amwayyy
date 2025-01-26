module "aws_auth" {
  source         = "../../../../bases/eks-aws-auth"
  eks_auth_roles = var.eks_cluster_config.eks_auth_roles
}

module "demo_cluster_ingress" {
  source = "../../../../bases/simple-ingress"

  eks_cluster_config = var.eks_cluster_config
  domain_info        = var.domain_info
  nginx_ingress_info = {
    domain_name               = var.domain_info.domain_name
    subject_alternative_names = var.domain_info.subject_alternative_names

  }
}
