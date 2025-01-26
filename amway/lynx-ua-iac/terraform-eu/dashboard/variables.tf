# ASG related vars
variable "disk_size" {
  default = 10
}

# S3 bucket name
variable "s3_bucket_name" {
  description = "Name of the u/c s3 dumps bucket"
  default     = "amway05-01-eu-central-1-dumps"
}

variable "s3_mount_dir" {
  description = "Mount path for the u/c s3 dump bucket"
  default     = "/opt/dashboard/ultraserve-dumps"
}

variable "s3_keys_secret_name" {
  description = "secret id containing aws key for an s3 bucket"
  default     = "amway05-01-eu-central-1-dumps"
}

variable "s3_mysql_be_bucket_name" {
  description = "Name of the mysql_be s3 bucket"
  default     = "amway-dev-eu-mysql-be"
}

variable "s3_mysql_be_mount_dir" {
  description = "Mount path for the mysql_be s3 bucket "
  default     = "/opt/dashboard/mysql-be"
}

variable "git_user_secret_name" {
  description = "secret id containing github user name and token"
  default     = "git_admin_user_4_enterprise"
}

variable "ga_builds_ro_name" {
  description = "secret id containing ga_builds_ro user name and password"
  default     = "ga-builds-ro-credentials"
}
