locals {
  federated_statements_with_eks_oidc = [
    for eks_oidc_provider in var.all_allowed_eks_oidc_providers : {
      Effect = "Allow"
      Principal : {
        "Federated" : eks_oidc_provider.oidcArn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition : {
        "StringEquals" : {
          "${eks_oidc_provider.oidcUrl}:aud" : "sts.amazonaws.com"
        }
      }
    }
  ]
}


module "amp-amg-iam-role" {
  source                       = "../../components/iam-role-with-policy"
  iam_role_name                = "${var.prometheus_workspace_alias}-amp-amg_role-"
  federated_statements         = local.federated_statements_with_eks_oidc
  iam_inline_policy_statements = var.amp_amg_iam_role_inline_policy
}

module "aws-managed-prometheus" {
  source          = "../../components/aws-managed-prometheus"
  workspace_alias = var.prometheus_workspace_alias
}


module "aws-managed-grafana" {
  source             = "../../components/aws-managed-grafana"
  workspace_name     = var.grafana_workspace_name
  data_sources       = var.grafana_data_sources
  role_assertion     = var.grafana_role_assertion
  editor_role_values = var.grafana_editor_role_values
  admin_role_values  = var.grafana_admin_role_values
  idp_metadata_url   = var.grafana_idp_metadata_url
}


resource "aws_s3_bucket" "this" {
  # The bucket name must be the fqdn it responds to
  bucket = var.grafana_host_s3_bucket

  website {
    redirect_all_requests_to = "https://${module.aws-managed-grafana.grafana_url.endpoint}"
  }
}

//resource "aws_route53_record" "this" {
//  zone_id = var.grafana_host_route53_zone_id
//  name = var.grafana_host_route53_record
//  type = "A"
//
//  alias {
//    name = "${aws_s3_bucket.this.bucket_domain_name}"
//    zone_id = "${aws_s3_bucket.this.hosted_zone_id}"
//    evaluate_target_health = true
//  }
//  depends_on = [
//    aws_s3_bucket.this]
//}

output "prometheus_url" {
  value = module.aws-managed-prometheus.prometheus_url
}

output "prometheus_export_arn" {
  value = module.amp-amg-iam-role.iam_role.arn
}

output "grafana_url" {
  value = module.aws-managed-grafana.grafana_url
}

output "grafana_role_arn" {
  value = module.aws-managed-grafana.grafana_role_arn
}
