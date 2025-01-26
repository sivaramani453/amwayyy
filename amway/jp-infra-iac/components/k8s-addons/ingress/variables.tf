variable "namespace" {
  type    = string
  default = "ingress-nginx"
}

variable "domain_name" {
  type = string
}

variable "ssl_certificate_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "nlb_name" {
  type = string
}

variable "set_list" {
  type    = map(string)
  default = {}
}

variable "trace_collector_service_account" {
  type    = string
  default = "collector"
}

variable "trace_collector" {
  type    = string
  default = "collector.linkerd-jaeger:55678"
}

variable "otlp_collector_host" {
  type    = string
  default = "collector.linkerd-jaeger.svc"
}

variable "otlp_collector_port" {
  type    = string
  default = "4317"
}

