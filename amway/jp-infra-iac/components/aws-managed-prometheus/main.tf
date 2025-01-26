module "prometheus" {
  source          = "terraform-aws-modules/managed-service-prometheus/aws"
  workspace_alias = var.workspace_alias
}

output "prometheus_url" {
  value = module.prometheus.workspace_prometheus_endpoint
}
