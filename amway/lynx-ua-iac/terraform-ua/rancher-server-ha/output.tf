output "cluster_name" {
  value = var.cluster_name
}

output "masters_private_ips" {
  value = module.kubernetes_cluster.masters_private_ips
}

output "workers_private_ips" {
  value = module.kubernetes_cluster.workers_private_ips
}

output "workers_ids" {
  value = module.kubernetes_cluster.workers_instance_ids
}

output "api_endpoint" {
  value = "https://${module.kubernetes_cluster.dns_name}:6443"
}

output "rancher_url" {
  value = aws_route53_record.rancher.fqdn
}

output "ingress_endpoint" {
  value = module.internal_ingress_lb.dns_name
}

output "s3_bucket_name" {
  value = module.kubernetes_cluster.s3_bucket_name
}

