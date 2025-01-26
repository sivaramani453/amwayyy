variable "prometheus_workspace_alias" {
  type        = string
  description = "The alias of the prometheus workspace."
}


variable "amp_amg_iam_role_inline_policy" {
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = [
    {
      "Effect" : "Allow",
      "Action" : [
        "aps:RemoteWrite",
        "aps:QueryMetrics",
        "aps:GetSeries",
        "aps:GetLabels",
        "aps:GetMetricMetadata"
      ],
      "Resource" : ["*"]
    }
  ]
}


variable "all_allowed_eks_oidc_providers" {
  type = list(object({
    oidcArn = string
    oidcUrl = string
  }))
  default = [
    {
      "oidcArn" : "arn:aws:iam::417642731771:oidc-provider/oidc.eks.ap-northeast-1.amazonaws.com/id/348C333BC86A0F0213B43D7C2E485E88",
      "oidcUrl" : "oidc.eks.ap-northeast-1.amazonaws.com/id/348C333BC86A0F0213B43D7C2E485E88",
    },
    {
      "oidcArn" : "arn:aws:iam::492449516969:oidc-provider/oidc.eks.ap-northeast-1.amazonaws.com/id/E78AE6C37FEEDC3022D59C18392A75DF",
      "oidcUrl" : "oidc.eks.ap-northeast-1.amazonaws.com/id/E78AE6C37FEEDC3022D59C18392A75DF",
    }
  ]
}

variable "grafana_workspace_name" {
  type        = string
  description = "The alias of the prometheus workspace."
}

variable "grafana_data_sources" {
  type        = list(string)
  description = "The alias of the prometheus workspace"
}

variable "grafana_role_assertion" {
  type        = string
  description = "The alias of the prometheus workspace"
}

variable "grafana_editor_role_values" {
  type        = list(string)
  description = "The alias of the prometheus workspace"
}

variable "grafana_admin_role_values" {
  type        = list(string)
  description = "The alias of the prometheus workspace"
}

variable "grafana_idp_metadata_url" {
  type        = string
  description = "The alias of the prometheus workspace"
}

variable "grafana_host_s3_bucket" {
  type        = string
  description = "The alias of the prometheus workspace"
}

variable "grafana_host_route53_record" {
  type        = string
  description = "The alias of the prometheus workspace"
}

variable "grafana_host_route53_zone_id" {
  type        = string
  description = "The alias of the prometheus workspace"
  default     = "Z3QFNC4QATXZ4Z"
}

