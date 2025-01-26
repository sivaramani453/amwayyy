module "aws_auth" {
  source         = "../../components/eks-aws-auth"
  eks_auth_roles = var.eks_auth_roles
}

output "aws_auth" {
  value = module.aws_auth.aws_auth
}
