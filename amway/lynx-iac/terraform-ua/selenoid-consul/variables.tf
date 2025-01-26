variable "region" {
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "consul_cluster_size" {
  description = "Count of nodes in cluster"
  default     = 3
}
