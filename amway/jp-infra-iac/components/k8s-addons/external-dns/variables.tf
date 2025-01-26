variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "txtOwnerId" {
  type        = string
  default     = "Z3QFNC4QATXZ4Z"
  description = "Variable indicating whether deployment is enabled."
}

variable "domainFilters" {
  type        = string
  default     = "preprod.jp.amway.net"
  description = "Variable indicating whether deployment is enabled."
}

variable "roleArn" {
  type        = string
  default     = "arn:aws:iam::417642731771:role/jpn-sandbox-eks-infra-support-iam-role20230704134002452000000001"
  description = "Variable indicating whether deployment is enabled."
}
