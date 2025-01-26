variable "url" {
  type        = string
  description = "The URL of the identity provider"
}

variable "client_id_list" {
  type        = any
  description = "A list of client IDs (also known as audiences)"
  default = [
    "sts.amazonaws.com"
  ]
}

variable "thumbprint_list" {
  type        = any
  description = "A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)."
  default     = []
}

