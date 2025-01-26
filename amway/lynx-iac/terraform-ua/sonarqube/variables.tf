## Credentials
variable "access_key" {}

variable "secret_key" {}
variable "region" {}

## EC2
variable "ec2_availability_zone" {
  type    = "string"
  default = "eu-central-1a"
}

variable "ec2_tag_name_suffix" {
  type = "string"
}

variable "ec2_subnet_id" {
  type    = "string"
  default = "subnet-0be51a63"
}

variable "ec2_ebs_optimized" {
  type    = "string"
  default = "true"
}

variable "ec2_instance_type" {
  type    = "string"
  default = "t3.xlarge"
}

variable "ec2_monitoring" {
  type    = "string"
  default = "false"
}

variable "ec2_key_name" {
  type    = "string"
  default = "EPAM-SE"
}

variable "ec2_vpc_id" {
  type    = "string"
  default = "vpc-1fbfbe76"
}

variable "ec2_vpc_security_group_ids" {
  type    = "list"
  default = ["sg-5689343e"]
}

variable "ec2_associate_public_ip_address" {
  type    = "string"
  default = "false"
}

variable "ec2_source_dest_check" {
  type    = "string"
  default = "true"
}

## Volumes
variable "root_volume_type" {
  type    = "string"
  default = "gp3"
}

variable "root_volume_size" {
  type    = "string"
  default = "50"
}

variable "root_volume_iops" {
  type    = "string"
  default = "1000"
}

variable "root_volume_delete_on_termination" {
  type    = "string"
  default = "true"
}

# Load Balancer
variable "lb_subnet_ids" {
  type    = "list"
  default = ["subnet-0be51a63", "subnet-bc84f7c1"]
}

variable "lb_is_internal" {
  type    = "string"
  default = "true"
}

variable "lb_type" {
  type    = "string"
  default = "application"
}

variable "lb_deletion_protection" {
  type    = "string"
  default = "false"
}

variable "lb_taget_group_port" {
  type    = "string"
  default = "9999"
}

variable "lb_taget_group_protocol" {
  type    = "string"
  default = "HTTP"
}

variable "lb_taget_group_type" {
  type    = "string"
  default = "ip"
}

variable "lb_taget_group_hc_protocol" {
  type    = "string"
  default = "HTTP"
}

variable "lb_taget_group_hc_path" {
  type    = "string"
  default = "/about"
}

variable "lb_taget_group_hc_response" {
  type    = "string"
  default = "200"
}

variable "lb_listener_protocol" {
  type    = "string"
  default = "HTTP"
}

variable "lb_listener_port" {
  type    = "string"
  default = "80"
}

variable "lb_listener_action" {
  type    = "string"
  default = "redirect"
}

# Route53
variable "r53_type" {
  type    = "string"
  default = "A"
}

variable "r53_zone_id" {
  type    = "string"
  default = "ZNTYJYCMRBH4S"
}

variable "r53_evaluate_hc" {
  type    = "string"
  default = "true"
}

variable "r53_ttl" {
  type    = "string"
  default = "300"
}
