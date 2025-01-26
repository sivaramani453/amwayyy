variable "namespace" {
  type = string
}

variable "high_availability" {
  type        = bool
  default     = false
  description = "Install Linkerd in high availability (HA) mode"
}

variable "chart_version" {
  type        = string
  description = "Specify the exact Linkerd chart version to install."
  default     = "2.11.1"
}

variable "cert_validity_period_hours" {
  description = "The number of hours after initial issuing that the certificate will become invalid."
  type        = number
  default     = 8760 # 1 year
}

variable "values" {
  type        = list(string)
  default     = []
  description = "List of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple -f options. Example: [\"enablePodAntiAffinity: false\"]"
}

variable "viz_enabled" {
  type        = bool
  default     = true
  description = "Install Linkerd-Viz: extension contains observability and visualization components"
}
