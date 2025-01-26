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

output "ingress_endpoint_internal" {
  value = "${module.internal-ingress-lb.dns_name}"
}

output "ingress_zone_internal" {
  value = "${module.internal-ingress-lb.zone_id}"
}

output "ingress_endpoint_external" {
  value = "${module.external-ingress-lb.dns_name}"
}

output "ingress_zone_external" {
  value = "${module.external-ingress-lb.zone_id}"
}

output "s3_bucket_name" {
  value = "${module.kubernetes-cluster.s3_bucket_name}"
}
