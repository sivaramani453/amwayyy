variable "enabled" {
  type        = bool
  default     = false
  description = "Variable indicating whether deployment is enabled."
}

variable "namespace" {
  type    = string
  default = "tracing"
}

variable "cluster_name" {
  type = string
}

variable "ingress_domain_name" {
  type = string
}
