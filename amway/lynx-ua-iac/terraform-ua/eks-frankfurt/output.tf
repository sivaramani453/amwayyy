output "api_endpoint" {
  value = "${module.eks.cluster_endpoint}"
}

output "cluster_certificate_authority_data" {
  value = "${module.eks.cluster_certificate_authority_data}"
}
