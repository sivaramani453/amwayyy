variable "default_tags" {
  type = map(string)
  default = {
    ApplicationID = "APP1433688",
    Contact       = "jose_flores@amway.com",
    Project       = "Hybris Reconciliation",
    Country       = "Japan",
    Environment   = "PROD"
  }
}

variable "eks_cluster_config" {
  type = any
}

variable "iam_role_name" {
  description = "Name for the IAM role"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to creatE"
  type        = string
}

variable "oidc_statement" {
  description = "OIDC configuration for GHA"
  type        = any
}

variable "s3_bucket_name_export" {
  description = "S3 bucket where the reconciliation files will be pushed"
  type        = string
}
