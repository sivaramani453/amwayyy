# ASG related vars
variable "disk_size" {
  default = 10
}

# ALB related vars
variable "dns_name" {
  description = "DNS name for alb"
  default     = "allure-reports.hybris.eu.eia.amway.net"
}

variable "user_agent" {
  type = string
}
