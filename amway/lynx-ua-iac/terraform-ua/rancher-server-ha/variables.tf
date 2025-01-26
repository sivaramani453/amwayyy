variable "cluster_name" {
  default = "rancher-cluster"
}

variable "master_count" {
  description = "Number of master nodes"
  default     = 3
}

variable "worker_count" {
  description = "Number of worker nodes"
  default     = 3
}

variable "rancher_node_port" {
  description = "Rancher service nodePort"
  default     = "30600"
}

