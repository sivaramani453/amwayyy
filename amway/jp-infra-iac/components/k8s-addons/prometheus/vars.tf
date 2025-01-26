variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "serviceAccount" {
  type        = string
  description = "RoleArn to give access to send metrics"
  default     = "amp-iamproxy-ingest-service-account"
}

variable "roleArn" {
  type        = string
  description = "RoleArn to give access to send metrics"
}

variable "remoteWriteUrl" {
  type        = string
  description = "Remote URL where metrics will be transferred"
}

variable "region" {
  type        = string
  description = "region"
  default     = "ap-northeast-1"
}
