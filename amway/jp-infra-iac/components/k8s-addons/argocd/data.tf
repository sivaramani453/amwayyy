variable "redis_vpc_id" {
  type        = string
  description = "Redis Group identifier"
  default     = "vpc-0d1aa036eb0120566"
}

variable "redis_cluster_id_prefix" {
  type        = string
  description = "Redis Group identifier"
  default     = "eks-argocd-storage"
}

variable "redis_cluster_size" {
  type        = number
  description = "Number of nodes in cluster"
  default     = 1
}

variable "redis_instance_type" {
  type        = string
  description = "Elastic cache instance type"
  default     = "cache.t2.micro"
}

variable "redis_engine_version" {
  type        = string
  description = "Redis engine version"
  default     = "3.2.10"
}

variable "redis_parameter_group_name" {
  type        = string
  description = "Redis engine version"
  default     = "default.redis3.2"
}

variable "redis_sg_name" {
  type        = string
  default     = ""
  description = "Name to give to created security group"
}
