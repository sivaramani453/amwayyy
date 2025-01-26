variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "set_list" {
  type    = map(string)
  default = {}
}

variable "elasticsearch_host" {
  type = string
}

variable "elasticsearch_user" {
  type = string
}

variable "elasticsearch_password" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type      = string
  sensitive = true
}

variable "jaeger_collector_endpoint" {
  type    = string
  default = "jaeger-collector.linkerd-jaeger:14250"
}

variable "otlp_collector_endpoint" {
  type    = string
  default = "jaeger-collector.linkerd-jaeger:4317"
}
