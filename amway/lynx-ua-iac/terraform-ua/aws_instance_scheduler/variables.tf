variable "environment" {
  description = "Environment name"
  default     = "aws-instance-scheduler"
}

variable "service" {
  description = "Service name"
  default     = "aws-instance-scheduler"
}

variable "cpu" {
  description = "Allocated amount of CPU"
  default     = 512
}

variable "memory" {
  description = "Allocated amount of memory"
  default     = 1024
}

variable "docker_registry" {
  description = "Docker registry name"
  default     = "nexus.hybris.eia.amway.net:8083"
}

variable "docker_image" {
  description = "Docker image name"
  default     = "aws_instance_scheduler"
}

variable "docker_image_tag" {
  description = "Docker image tag"
  default     = "0.1"
}

variable "container_port" {
  description = "Port to expose from container"
  default     = 5000
}

variable "certificate_arn" {
  description = "Certificate ARN for ALB"
  default     = "arn:aws:acm:eu-central-1:860702706577:certificate/3bce1dc0-e691-4521-9fca-4f5430776282"
}

variable "aws_secrets_manager_secret_arn" {
  description = "ARN of specific AWS Secrets Manager secret which stores credentials for accessing private docker images registry"
  default     = "arn:aws:secretsmanager:eu-central-1:860702706577:secret:dockerregistry-u8GKp6"
}

variable "instance-scheduler-config-table-name" {
  description = "instance-scheduler config table name in dynamodb, created by AWS solution"
  default     = "amway-instance-scheduler-ConfigTable-3WM26WVP6TBP"
}

variable "instance-scheduler-users-table-name" {
  description = "instance-scheduler users table name in dynamodb, created by init script"
  default     = "amway-instance-scheduler-users"
}

variable "instance-scheduler-groups-table-name" {
  description = "instance-scheduler groups table name in dynamodb, created by init script"
  default     = "amway-instance-scheduler-groups"
}

variable "instance-scheduler-default-schedules-table-name" {
  description = "instance-scheduler groups table name in dynamodb, created by init script"
  default     = "amway-instance-scheduler-default-schedules"
}
