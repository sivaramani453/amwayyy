variable "set_list" {
  type    = map(string)
  default = {}
}

variable "loki_clients_url" {
  type    = string
  default = "http://loki-loki-distributed-distributor.tracing.svc.cluster.local:3100/loki/api/v1/push"
}
