variable "eks_version" {
  type        = string
  default     = "1.27"
  description = "Kubernetes version. Defaluts to 1.27"
}

variable "eks_role_arn" {
  type        = string
  description = "IAM Role ARN to associate with this cluster"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of strings of subnet IDs to associate with this cluster"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of strings of security group IDs to add to the cluster"
}

variable "name" {
  type        = string
  description = "Name of the EKS Cluster"
}

variable "node_groups" {
  type = any
}

variable "default_tags" {
  type = map(string)
}

variable "eks_extra_tags" {
  type    = map(string)
  default = {}
}
