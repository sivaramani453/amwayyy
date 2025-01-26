variable "ami" {
  description = "ami to use (diff hybris version)"
}

variable "instance_name" {
  description = "Name of dev-debug machine"
}

variable "db_volume_snapshot" {
  description = "Name of dev-debug machine"
}

variable "media_volume_snapshot" {
  description = "Name of dev-debug machine"
}

variable "custom_tags_instance" {
  type        = "map"
  description = "Amway custom tags for ec2instance with values"
}

variable "custom_tags_volume" {
  type        = "map"
  description = "Amway custom tags for ec2volume with values"
}

variable "custom_tags_common" {
  type        = "map"
  description = "Amway custom tags for ec2volume and ec2instance with values"
}
