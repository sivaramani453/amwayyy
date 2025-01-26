variable "ec2_be_instance_type" {
  description = "Instance type for Backend nodes"
  default     = "m5a.xlarge"
}

variable "ec2_fe_instance_type" {
  description = "Instance type for Frontend nodes"
  default     = "m5a.xlarge"
}

variable "ec2_be_instance_count" {
  description = "Instance number for Backend nodes"
  default     = "2"
}

variable "ec2_fe_instance_count" {
  description = "Instance number for Frontend nodes"
  default     = "2"
}

variable "media_volume_device_name" {
  description = "Media volume device name"
  default     = "/dev/sdf"
}

variable "db_volume_device_name" {
  description = "Database volume device name"
  default     = "/dev/sdg"
}

variable "ext_balancer_fe_acl" {
  description = "List of allowed ips for the security group of the FE external balancer"
  type        = list(string)
  default     = [""]
}

variable "ext_balancer_be_acl" {
  description = "List of allowed ips for the security group of the BE external balancer"
  type        = list(string)
  default     = [""]
}
