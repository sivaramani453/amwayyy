## EC2
variable "ec2_env_suffix" {
  description = "Region related suffix: eu or ru"
}

variable "ec2_availability_zone" {
  description = "Availability zone"
  default     = "eu-central-1a"
}

variable "ec2_be_instance_type" {
  description = "Instance type for Backend nodes"
  default     = "m5.xlarge"
}

variable "ec2_fe_instance_type" {
  description = "Instance type for Frontend nodes"
  default     = "m5.xlarge"
}

variable "ec2_be_instance_count" {
  description = "Instance number for Backend nodes"
  default     = "2"
}

variable "ec2_fe_instance_count" {
  description = "Instance number for Frontend nodes"
  default     = "2"
}

variable "ec2_instance_iam_profile" {
  description = "Instance IAM profile to retrieve tags"
  default     = "env-deployment-tags"
}

variable "ec2_private_ip_be1" {
  description = "Private Ip adress for BE1 node"
}

variable "ec2_private_ip_be2" {
  description = "Private Ip adress for BE2 node"
}

variable "ec2_private_ip_fe1" {
  description = "Private Ip adress for FE1 node"
}

variable "ec2_private_ip_fe2" {
  description = "Private Ip adress for FE2 node"
}

## Volumes
# Root
variable "root_volume_type" {
  description = "Root volume type"
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root volume size"
  default     = 15
}

# Media
variable "media_volume_device_name" {
  description = "Media volume device name"
  default     = "/dev/sdf"
}

# Database
variable "db_volume_device_name" {
  description = "Database volume device name"
  default     = "/dev/sdg"
}

## Route53
variable "r53_countries" {
  description = "Countries suffixes for DNS names in Route 53"
  default     = ["be", "dk", "es", "fi", "nl", "no", "pt", "se", "ru", "kz", "at", "ch", "co.uk", "ie", "gr", "it", "de", "fr", "ro", "tr", "pl", "cz", "ee", "si", "bg", "hr", "lt", "ua", "hu", "lv", "sk"]
}

variable "r53_records_count" {
  description = "Total amount of DNS names, should be equal to suffixes for DNS names"
  default     = 31
}

## ALB
variable "alb_listener_forward_certificate_arn" {
  description = "SSL certificate ARN from Amazon ACM"
  default     = "arn:aws:acm:eu-central-1:860702706577:certificate/7945c96d-6572-49a3-98ab-5989ae12e3bb"
}

variable "alb_security_policy" {
  description = "SSL security policy for the LB"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "alb_taget_group_hc_path" {
  description = "Health check path"
  default     = "/hmc/hybris"
}
