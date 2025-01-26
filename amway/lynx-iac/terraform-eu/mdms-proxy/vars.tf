variable "service" {
  description = "Environment name"
  default     = "MDMSproxy"
}

variable "certificate_arn" {
  description = "Certificate ARN for ALB"
  default     = "arn:aws:acm:eu-central-1:860702706577:certificate/3bce1dc0-e691-4521-9fca-4f5430776282"
}

variable "amway_env_type" {
  type        = string
  description = "Environment tag type according to Amway's tag specification"
  default     = "DEV"
}
