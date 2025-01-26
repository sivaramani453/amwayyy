variable "root_password" {
  type        = "string"
  description = "Password of the root user for PostgreSQL database"
  default     = ""
}

variable "engine_version" {
  type        = "string"
  description = "Engine version of the PostgreSQL database"
  default     = "11.8"
}

variable "major_engine_version" {
  type        = "string"
  description = "Major engine version of the PostgreSQL database"
  default     = "11"
}

variable "pg_user_name" {
  type        = "string"
  description = "Role name for the PostgreSQL database"
  default     = "mauser"
}

variable "pg_user_pass" {
  type        = "string"
  description = "Password of the role for PostgreSQL database"
}

variable "AWS_user_arn" {
  type        = "string"
  description = "ARN of the user or role to work with S3 buckets"
  default     = "arn:aws:iam::860702706577:role/AWS-CDA-860702706577-CONTRIB"
}

variable "AWS_runner_arn" {
  type        = "string"
  description = "ARN of the ECS cluster with runners to deploy to S3 buckets"
  default     = "arn:aws:iam::860702706577:role/ecs-task-role-ga-dev-cluster"
}

variable "alb_domain" {
  type        = "string"
  description = "Domain name for stage ALB"
  default     = "marketplace-auth-dev.hybris.eia.amway.net"
}

variable "hosted_zone_id" {
  type        = "string"
  description = "Route53 hosted zone id - default is dev"
  default     = "ZNTYJYCMRBH4S"
}

