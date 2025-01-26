variable "ami" {
  description = "ami to use (diff hybris version)"
}

variable "instance_name" {
  description = "the name of a dev-debug machine"
}

variable "db_volume_snapshot" {
  description = "snapshot id of the database"
}

variable "media_volume_snapshot" {
  description = "snapshot id of the media"
}
