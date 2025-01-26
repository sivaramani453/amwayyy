variable "default_tags" {
  type = map(string)
}

variable "eks_cluster_config" {
  type = any
}

variable "node_groups" {
  type = any
}

variable "domain_info" {
  type = object({
    route53_zone = string
    txtOwnerId   = string
  })
}

variable "common_infra_support_arn" {
  type = string
}


variable "prometheus" {
  description = "Prometheus configuration"
  type = object({
    roleArn        = string
    remoteWriteUrl = string
  })
}

variable "argocd" {
  description = "argocd configuration"
  type = object({
    argocd_server_host = string

    argocd_github_connector_user_name = string
    argocd_github_connector_password  = string
    argocd_github_org_url             = string

    argocd_ingress_enabled = bool
  })
}
