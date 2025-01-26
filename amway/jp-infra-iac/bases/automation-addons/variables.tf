variable "common_infra_support_arn" {
  description = "Token to access Splunk"
  type        = string
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

variable "github_auth" {
  description = "Authentication with GitHub, either as a PAT or as a GitHub app details. This will be stored in a secret. This should be key-value pairs."
  type        = map(string)
}

variable "github_config_url" {
  description = "Repo or organization URL (https://github.com/org/repo) where this runner will exist"
  type        = string
}

variable "runner_name" {
  description = "Name of hte main runner scale set"
  type        = string
}
