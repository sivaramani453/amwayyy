## EC2
variable "ec2_env_name" {
  description = "Environment name"
}

variable "ec2_env_suffix" {
  description = "REgion related suffix: eu or ru"
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

variable "ec2_availability_zone" {
  description = "Availability zone"
  default     = "eu-central-1a"
}

variable "ec2_instance_type" {
  description = "Instance type"
  default     = "m5.xlarge"
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
  default     = ["be", "dk", "es", "fi", "nl", "no", "pt", "se", "ru", "kz", "at", "ch", "co.uk", "ie", "gr", "it", "de", "fr"]
}

variable "r53_records_count" {
  description = "Total amount of DNS names, should be equal to suffixes for DNS names"
  default     = 18
}

# Load Balancer
variable "lb_subnet_ids" {
  description = "Subnets for load balancer"
  default     = ["subnet-0be51a63", "subnet-bc84f7c1"]
}

variable "lb_taget_group_port" {
  description = "Port on target machine where all requests are being redirected from load balancer"
  default     = 9002
}

variable "lb_taget_group_protocol" {
  description = "Protocol on target machine where all requests are being redirected from load balancer"
  default     = "HTTPS"
}

variable "lb_taget_group_hc_protocol" {
  description = "Health check protocol"
  default     = "HTTPS"
}

variable "lb_taget_group_hc_path" {
  description = "Health check path"
  default     = "/hmc/hybris"
}

variable "lb_taget_group_hc_response" {
  description = "Expected health check response"
  default     = 200
}

variable "lb_taget_group_stickiness_cookie_duration" {
  description = "Load balancerr sticky session duration"
  default     = 86400
}

variable "lb_listener_forward_certificate_arn" {
  description = "SSL certificate ARN from Amazon ACM"
}

variable "lb_taget_group_port_storybook" {
  description = "Port for Storybook on target machine where all requests are being redirected from load balancer"
  default     = 9090
}

variable "lb_taget_group_protocol_storybook" {
  description = "Protocol for Storybook on target machine where all requests are being redirected from load balancer"
  default     = "HTTP"
}

variable "lb_taget_group_hc_protocol_storybook" {
  description = "Health check protocol for Storybook"
  default     = "HTTP"
}

variable "lb_taget_group_hc_path_storybook" {
  description = ""
  default     = "/"
}

variable "lb_taget_group_hc_response_storybook" {
  description = "Expected health check response for Storybook"
  default     = 200
}
