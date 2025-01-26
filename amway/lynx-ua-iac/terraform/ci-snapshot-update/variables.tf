variable "is_env" {
  description = "Attach the database volume of an envrionment"
  default     = false
}

variable "is_env_media" {
  description = "Attach the media volume of an envrionment"
  default     = false
}

variable "env_media_volume_snapshot" {
  description = "Snapshot ID of a media volume of an environment"
}

variable "env_db_volume_snapshot" {
  description = "Snapshot ID of a database volume for an environment"
}

variable "ci_db_volume_snapshot" {
  description = "Snapshot ID of a database volume for the CI"
}
