variable "waf_enabled" {
  type        = bool
  description = "WAF ip filter should be enabled on non-prod envs and disabled on production"
  default     = true
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for distribution aliases"
#  default     = "www.fqa.amway.ru"
}

variable "hybris_domain" {
  type        = string
  description = "Domain name for hybris ALB"
#  default     = "www.fqa.amway.ru"
}

variable "hybris_domain_short" {
  type        = string
  description = "Domain name for hybris ALB without www"
#  default     = "fqa.amway.ru"
}

variable "hybris_alb" {
  type        = string
  description = "ALB host name"
#  default     = "gat8b65a1d384afe8846e220d5e9e246-2982933f23d30d92.elb.eu-central-1.amazonaws.com"
}

variable "prerender_host" {
  type        = string
  description = "Domain name for hybris ALB"
#  default     = "prerender.amway.ru"
}

variable "custom_header" {
  type        = string
  description = "Custom header value to access to ALB"
#  default     = "CF_NFT-4cce55-T0k3n"
}

#variable "hosted_zone_id" {
#  type        = string
#  description = "Route53 hosted zone id - default is dev"
#  default     = "ZNTYJYCMRBH4S"
#}

variable "aws_user_arn" {
  type        = string
  description = "ARN of the user or role to work with S3 buckets"
  default     = "arn:aws:iam::645993801158:role/AWS-CDA-645993801158-CONTRIB"
}

variable "aws_runner_arn" {
  type        = string
  description = "ARN of the ECS cluster with runners to deploy to S3 buckets"
  default     = "arn:aws:iam::860702706577:role/ecs-task-role-ga-dev-cluster"
}
