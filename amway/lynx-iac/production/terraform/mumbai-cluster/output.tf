output "cluster_name" {
  value = "${var.cluster_name}"
}

output "masters_private_ips" {
  value = "${module.kubernetes-cluster.masters_private_ips}"
}

output "workers_private_ips" {
  value = "${module.kubernetes-cluster.workers_private_ips}"
}

output "api_endpoint" {
  value = "https://${module.kubernetes-cluster.dns_name}:6443"
}

output "ingress_endpoint" {
  value = "${module.internal-ingress-lb.dns_name}"
}

output "s3_bucket_name" {
  value = "${module.kubernetes-cluster.s3_bucket_name}"
}
