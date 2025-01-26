variable "default_tags" {
  type = map(string)
}

variable "node_groups" {
  description = "Map of definition for each node group. See variables.tf for examples."
  type        = any
}

variable "domain_info" {
  description = "Information about the domain and SSL"
  type        = any
}

variable "eks_cluster_config" {
  description = "Configuration object for the EKS cluster"
  type        = any
}
