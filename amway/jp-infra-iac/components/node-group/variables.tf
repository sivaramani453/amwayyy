variable "name" {
  type        = string
  description = "Name of the EKS Node Group"
}

variable "scaling_config" {
  description = "Scaling configuration, requires max_size, min_size and desired_size"
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster to associate with this node group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to associate with nodes in this node group"
}

variable "capacity_type" {
  type        = string
  description = "Instance capacity type: SPOT or ONDEMAND"

  validation {
    condition = contains([
      "SPOT",
    "ONDEMAND"], var.capacity_type)
    error_message = "Allowed values for input_parameter are \"SPOT\" or \"ONDEM<AND\"."
  }
}

variable "node_group_iam_role" {
  type = string
}
