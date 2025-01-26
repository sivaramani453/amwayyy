variable "default_tags" {
  type = map(string)
  default = {
    ApplicationID = "APPXXXXXX",
    Contact       = "dayu_you@amway.com",
    Project       = "JP-ACSD-PSS-DATA",
    Country       = "Japan",
    Environment   = "DEV"
  }
}

variable "oidc_statement" {
  type = any
}

variable "dynamo_table_name" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "iam_role_name" {
  type = string
}
