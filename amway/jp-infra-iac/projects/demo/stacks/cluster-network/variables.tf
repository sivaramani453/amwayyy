variable "default_tags" {
  type = map(string)
}

variable "domain_info" {
  type = any
}

variable "eks_cluster_config" {
  description = "Configuration object for the EKS cluster"
  type        = any
}

variable "node_groups" {
  description = "unused"
  type        = any
}
