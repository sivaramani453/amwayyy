output "api_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "worker_iam_role_name" {
  value = module.eks.worker_iam_role_name
}

