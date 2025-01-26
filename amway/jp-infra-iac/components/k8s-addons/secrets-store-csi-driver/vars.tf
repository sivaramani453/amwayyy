variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "kubernetes_csi_secret_namespace" {
  description = "Namespace to release csi_secret into"
  type        = string
  default     = "kube-system"
}

variable "csi_secret_helm_chart_version" {
  description = "csi_secret helm chart version to use"
  type        = string
  default     = ""
}

variable "syncSecret" {
  description = "syncSecret"
  type        = bool
  default     = true
}

variable "enableSecretRotation" {
  description = "enableSecretRotation"
  type        = bool
  default     = true
}
