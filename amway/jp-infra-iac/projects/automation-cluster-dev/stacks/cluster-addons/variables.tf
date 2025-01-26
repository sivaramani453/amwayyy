variable "default_tags" {
  type = map(string)
}

variable "eks_cluster_config" {
  type = any
}

variable "domain_info" {
  type = any
}

variable "github_auth" {
  type = map(string)
}

variable "argocd" {
  type = any
}

variable "github_config_url" {
  type = string
}
