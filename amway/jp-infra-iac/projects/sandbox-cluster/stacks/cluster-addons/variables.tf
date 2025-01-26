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

variable "splunk_token" {
  type = string
}

variable "komodor_api_key" {
  type = string
}

variable "argocd_server_host" {
  description = "Hostname for argocd (will be utilised in ingress if enabled)"
  type        = string
}

variable "eks_iam_argocd_role_name" {
  description = "IAM EKS service account role name for Argo CD"
  type        = string
}

variable "jaeger" {
  description = "Elasticsearch configuration"
  type = object({
    ingress_domain_name    = string
    elasticsearch_host     = string
    elasticsearch_user     = string
    elasticsearch_password = string
  })
}

variable "jaeger_dns_info" {
  type = object({
    domain_name               = string
    subject_alternative_names = list(string)
  })
}

variable "loki" {
  description = "Loki configuration"
  type = object({
    ingress_domain_name = string
    storage_region      = string
    storage_region      = string
    storage_dynamodb    = string
    storage_s3_bucket   = string
  })
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
