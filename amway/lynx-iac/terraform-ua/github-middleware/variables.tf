variable "certificate_arn" {
  description = "Certificate ARN from AWS ACM"
  default     = "arn:aws:acm:eu-central-1:860702706577:certificate/f86d17e3-57f6-403f-a618-f7653b32a5a8"
}

variable "service" {
  description = "Service name"
  default     = "github-middleware"
}
