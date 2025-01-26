## EC2                                                                                                                   
variable "ec2_pl_nodes_count" {
  description = "Node number for Product Labeling"
  default     = "1"
}

variable "ec2_pl_nodes_instance_type" {
  description = "Instance type for Product Labeling Nodes"
  default     = "t3.medium"
}

variable "ec2_instance_iam_profile" {
  description = "Instance IAM profile to retrieve tags"
  default     = "env-deployment-tags"
}

## ALB
variable "alb_listener_forward_certificate_arn" {
  description = "SSL certificate ARN from Amazon ACM"
  default     = "arn:aws:acm:eu-central-1:860702706577:certificate/efae932f-a7bc-417f-bdd9-95c14f84699f"
}

variable "alb_security_policy" {
  description = "SSL security policy for the LB"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "alb_taget_group_hc_path" {
  description = "Health check path"
  default     = "/actuator/health"
}

variable "alb_taget_group_hc_port" {
  description = "Health check port"
  default     = "9001"
}
