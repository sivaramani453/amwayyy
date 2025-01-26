module "eks-managed-prometheus-grafana" {
  source                       = "../../bases/aws-managed-prometheus-grafana"
  prometheus_workspace_alias   = var.prometheus_workspace_alias
  grafana_workspace_name       = var.grafana_workspace_name
  grafana_role_assertion       = var.grafana_role_assertion
  grafana_data_sources         = var.grafana_data_sources
  grafana_admin_role_values    = var.grafana_admin_role_values
  grafana_editor_role_values   = var.grafana_editor_role_values
  grafana_idp_metadata_url     = var.grafana_idp_metadata_url
  grafana_host_s3_bucket       = var.grafana_host_s3_bucket
  grafana_host_route53_record  = var.grafana_host_route53_record
  grafana_host_route53_zone_id = var.grafana_host_route53_zone_id

  providers = {
    aws              = aws
    aws.oidc_creator = aws.oidc_creator
  }
}

output "prometheus_info" {
  value = {
    export_endpoint : module.eks-managed-prometheus-grafana.prometheus_url
    export_role_arn : module.eks-managed-prometheus-grafana.prometheus_export_arn
  }
}

output "grafana_info" {
  value = {
    endpoint : module.eks-managed-prometheus-grafana.grafana_url
    role_arn : module.eks-managed-prometheus-grafana.grafana_role_arn
  }
}
