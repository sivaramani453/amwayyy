variable "dns" {
  type        = string
  description = "Main DNS name without .amway.ru"
  default     = "static"
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
  default     = "static.amway.ua"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone id"
  default     = "Z01793602SX7SQ8XPUE1A"
}
