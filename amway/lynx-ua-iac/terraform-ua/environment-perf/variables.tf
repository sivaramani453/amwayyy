## EC2
variable "ec2_env_name" {
  description = "Environment name"
  default     = "perf"
}

variable "ec2_private_ip_be1" {
  description = "Private Ip adress for BE1 node"
  default     = "10.130.123.128"
}

variable "ec2_private_ip_be2" {
  description = "Private Ip adress for BE2 node"
  default     = "10.130.113.83"
}

variable "ec2_private_ip_fe1" {
  description = "Private Ip adress for FE1 node"
  default     = "10.130.123.129"
}

variable "ec2_private_ip_fe2" {
  description = "Private Ip adress for FE2 node"
  default     = "10.130.113.84"
}

variable "ec2_private_ip_fe3" {
  description = "Private Ip adress for FE3 node"
  default     = "10.130.123.130"
}

variable "ec2_private_ip_fe4" {
  description = "Private Ip adress for FE4 node"
  default     = "10.130.113.85"
}

variable "ec2_private_ip_of1" {
  description = "Private Ip adress for OF1 node"
  default     = "10.130.123.131"
}

variable "ec2_private_ip_of2" {
  description = "Private Ip adress for OF2 node"
  default     = "10.130.113.86"
}

variable "ec2_private_ip_solr_master" {
  description = "Private Ip adress for Solr Master node"
  default     = "10.130.123.132"
}

variable "ec2_private_ip_solr_slave_a" {
  description = "Private Ip adress for Solr Slave A node"
  default     = "10.130.123.133"
}

variable "ec2_private_ip_solr_slave_b" {
  description = "Private Ip adress for Solr Slave B node"
  default     = "10.130.113.87"
}

variable "ec2_availability_zone_1" {
  description = "Availability zone"
  default     = "eu-central-1a"
}

variable "ec2_availability_zone_2" {
  description = "Availability zone"
  default     = "eu-central-1b"
}

variable "ec2_instance_type_hybris" {
  description = "Instance type"
  default     = "m5.xlarge"
}

variable "ec2_instance_type_solr" {
  description = "Instance type"
  default     = "c4.large"
}

# RDS Aurora
variable "rds_instance_class" {
  description = "RDS Instance type"
  default     = "db.r5.large"
}

variable "db_root_password" {
  description = "Password for DB root user"
}

variable "db_engine_version" {
  description = "DB engine version"
  default     = "5.6.mysql_aurora.1.19.0"
}

variable "rds_preferred_backup_window" {
  description = "When to perform DB backups"
  default     = "02:00-03:00"
}

variable "rds_preferred_maintenance_window" {
  description = "When to perform DB maintenance"
  default     = "sun:05:00-sun:06:00"
}

variable "monitoring_interval" {
  description = "With this interval metrics are collected for the DB instance"
  default     = "60"
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

## Route53
variable "r53_countries" {
  description = "Countries suffixes for DNS names in Route 53"
  default     = ["be", "dk", "es", "fi", "nl", "no", "pt", "se", "at", "ch", "co.uk", "ie", "gr", "it", "de", "fr"]
}

variable "r53_records_count" {
  description = "Total amount of DNS names, should be equal to suffixes for DNS names"
  default     = 16
}

# Load Balancer
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
  default     = "arn:aws:acm:eu-central-1:860702706577:certificate/efae932f-a7bc-417f-bdd9-95c14f84699f"
}
