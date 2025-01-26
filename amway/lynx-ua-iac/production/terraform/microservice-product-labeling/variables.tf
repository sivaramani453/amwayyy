## EC2                                                                                                                   
variable "ec2_pl_nodes_count" {
  description = "Node number for Product Labeling"
  default     = "3"
}

variable "ec2_pl_nodes_instance_type" {
  description = "Instance type for Product Labeling Nodes"
  default     = "t3.medium"
}

variable "ec2_instance_iam_profile" {
  description = "Instance IAM profile"
  default     = "product-labeling-iam-role"
}

## ALB
variable "alb_listener_forward_certificate_arn" {
  description = "SSL certificate ARN from Amazon ACM"
  default     = "arn:aws:acm:eu-central-1:419521102043:certificate/27e3c66c-9478-4620-aec0-2d73c9db7e20"
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
