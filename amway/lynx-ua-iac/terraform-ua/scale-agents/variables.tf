variable "environment" {
  description = "Environment name"
  default     = "epam-scale-agents"
}

variable "service" {
  description = "Environment name"
  default     = "scale-agents"
}

variable "cpu" {
  description = "Allocated amount of CPU"
  default     = 256
}

variable "memory" {
  description = "Allocated amount of memory"
  default     = 512
}

variable "docker_image" {
  description = "Docker image name"
  default     = "860702706577.dkr.ecr.eu-central-1.amazonaws.com/scale_agents"
}

variable "docker_image_tag" {
  description = "Docker image tag"
  default     = "latest"
}
