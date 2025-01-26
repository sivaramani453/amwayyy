variable "ecs_service_name" {
  description = "The name of the bamboo scale agent ecs service"
  default     = "bamboo-scale-agent-eu"
}

variable "container_image_name" {
  description = "The name of the continaer image in the ecr"
  default     = "744058822102.dkr.ecr.eu-central-1.amazonaws.com/bamboo-scale-agent-eu:v0.4"
}
