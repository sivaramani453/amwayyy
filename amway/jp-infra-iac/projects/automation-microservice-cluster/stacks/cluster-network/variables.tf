variable "default_tags" {
  type = map(string)
}

variable "domain_info" {
  type = object({
    route53_zone = string
    txtOwnerId   = string
  })
}

variable "nginx_ingress_info" {
  type = object({
    domain_name               = string
    subject_alternative_names = list(string)
  })
}

variable "eks_cluster_config" {
  description = "Configuration object for the EKS cluster"
  type        = any
}

variable "node_groups" {
  description = "unused"
  type        = any
}
