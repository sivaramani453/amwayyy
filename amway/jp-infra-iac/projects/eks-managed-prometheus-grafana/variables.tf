variable "default_tags" {
  type = map(string)
  default = {
    ApplicationID = "APPXXXXXX",
    Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
    Project       = "AJ_INFRA_POC",
    Country       = "Japan",
    Environment   = "DEV"
  }
}

variable "prometheus_workspace_alias" {
  type        = string
  description = "The alias of the prometheus workspace."
  default     = "eks-common-prometheus"
}

variable "grafana_workspace_name" {
  type        = string
  description = "The alias of the prometheus workspace."
  default     = "eks-common-grafana"
}

variable "grafana_data_sources" {
  type        = list(string)
  description = "The alias of the prometheus workspace"
  default     = ["PROMETHEUS"]
}

variable "grafana_role_assertion" {
  type        = string
  description = "The alias of the prometheus workspace"
  default     = "user_name"
}

variable "grafana_editor_role_values" {
  type        = list(string)
  description = "The alias of the prometheus workspace"
  default     = ["sde"]
}

variable "grafana_admin_role_values" {
  type        = list(string)
  description = "The alias of the prometheus workspace"
  default     = ["anik_barua@amway.com"]
}

variable "grafana_idp_metadata_url" {
  type        = string
  description = "The alias of the prometheus workspace"
  default     = "https://dev-1474319.okta.com/app/exkadath76z9XB00H5d7/sso/saml/metadata"
}

variable "grafana_host_s3_bucket" {
  type        = string
  description = "The alias of the prometheus workspace"
  default     = "aj-grafana.preprod.jp.amway.net"
}

variable "grafana_host_route53_record" {
  type        = string
  description = "The alias of the prometheus workspace"
  default     = "aj-grafana"
}

variable "grafana_host_route53_zone_id" {
  type        = string
  description = "The alias of the prometheus workspace"
  default     = "Z3QFNC4QATXZ4Z"
}
