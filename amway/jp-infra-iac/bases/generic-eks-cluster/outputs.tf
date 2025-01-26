output "eks_cluster" {
  value = module.eks_cluster.cluster
}

output "common_infra_support_arn" {
  value = module.eks_infra_support_common_iam_role.iam_role.arn
}
