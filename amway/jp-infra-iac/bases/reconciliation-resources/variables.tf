variable "iam_role_name" {
  description = "Name for the IAM role"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to creatE"
  type        = string
}

variable "oidc_statement" {
  description = "OIDC configuration for the GitHub Actions OIDC"
  type        = any
}

variable "s3_bucket_name_export" {
  description = "Bucket name where the recon files should be pushed"
  type        = string
}
