variable "common_infra_support_arn" {
  description = "Token to access Splunk"
  type        = string
}

variable "eks_cluster_config" {
  description = "Configuration object for the EKS cluster"
  type = object({
    name               = string
    vpc_id             = string
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
}

variable "domain_info" {
  type = object({
    route53_zone = string
    txtOwnerId   = string
  })
}
