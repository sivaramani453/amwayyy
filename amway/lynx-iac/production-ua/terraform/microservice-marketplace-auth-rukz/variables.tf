variable "dns" {
  type        = string
  description = "Main DNS name without .amway.ru"
  default     = "marketplace-auth"
}

variable "root_password" {
  type        = string
  description = "Password of the root user for PostgreSQL database"
  default     = ""
}

variable "engine_version" {
  type        = string
  description = "Engine version of the PostgreSQL database"
  default     = "11.8"
}

variable "major_engine_version" {
  type        = string
  description = "Major engine version of the PostgreSQL database"
  default     = "11"
}

variable "pg_user_name" {
  type        = string
  description = "Role name for the PostgreSQL database"
  default     = "mauser"
}

variable "pg_user_pass" {
  type        = string
  description = "Password of the role for PostgreSQL database"
}

variable "AWS_user_arn" {
  type        = string
  description = "ARN of the user or role to work with S3 buckets"
  default     = "arn:aws:iam::645993801158:role/AWS-CDA-645993801158-CONTRIB"
}

variable "AWS_runner_arn" {
  type        = string
  description = "ARN of the ECS cluster with runners to deploy to S3 buckets"
  default     = "arn:aws:iam::645993801158:role/ecs-task-role-ga-prod-cluster"
}

variable "alb_domain" {
  type        = string
  description = "Domain name for ALB"
  default     = "marketplace-auth.ru.eia.amway.net"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone id"
  default     = "Z01793602SX7SQ8XPUE1A"
}
