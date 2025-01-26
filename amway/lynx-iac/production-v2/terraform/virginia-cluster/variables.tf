variable "cluster_name" {
  default = "virginia-cluster"
}

variable "master_count" {
  description = "Number of master nodes"
  default     = 5
}

variable "worker_count" {
  description = "Number of worker nodes"
  default     = 6
}
