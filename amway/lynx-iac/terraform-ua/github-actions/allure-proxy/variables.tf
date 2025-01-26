# ASG related vars
variable "disk_size" {
  default = 10
}

variable "key_pair_name" {
  default = "EPAM-SE"
}

# ALB related vars
variable "dns_name" {
  description = "DNS name for alb"
  default     = "allure-reports.hybris.eia.amway.net"
}

variable "cert_arn" {
  default = "arn:aws:acm:eu-central-1:860702706577:certificate/efae932f-a7bc-417f-bdd9-95c14f84699f"
}

# Proxy related vars
variable "s3_name" {
  type    = "string"
  default = "allure-reports"
}

variable "user_agent" {
  type = "string"
}

variable "allow_ip" {
  default = "52.58.207.210/32"
}

variable "app_id" {
  default = "APP1433689"
}

variable "app_env" {
  default = "test"
}
