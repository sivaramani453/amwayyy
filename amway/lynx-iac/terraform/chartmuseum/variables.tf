variable "environment" {
  description = "Environment name"
  default     = "epam"
}

variable "service" {
  description = "Environment name"
  default     = "chartmuseum"
}

variable "cpu" {
  description = "Allocated amount of CPU"
  default     = 512
}

variable "memory" {
  description = "Allocated amount of memory"
  default     = 1024
}

variable "docker_image" {
  description = "Docker image name"
  default     = "chartmuseum/chartmuseum"
}

variable "docker_image_tag" {
  description = "Docker image tag"
  default     = "v0.8.2"
}

variable "container_port" {
  description = "Port to expose from container"
  default     = 8080
}

variable "app_storage" {
  description = "Backend for chartmuseum"
  default     = "amazon"
}

variable "app_chart_url" {
  description = "Server URL for chartmuseum"
  default     = "https://chartmuseum.hybris.eia.amway.net"
}

variable "certificate_arn" {
  description = "Certificate ARN for ALB"
  default     = "arn:aws:acm:eu-central-1:860702706577:certificate/3bce1dc0-e691-4521-9fca-4f5430776282"
}
