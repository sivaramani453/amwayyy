variable "efs_ap_arn" {
  description = "Access point ARN of the EFS"
  type        = "string"
}

variable "efs_mount_path" {
  description = "EFS mount path for the Lambda"
  type        = "string"
  default     = "/mnt/efs"
}

variable "retention_days" {
  description = "Retention period for the EFS backups"
  type        = "string"
  default     = "60"
}
