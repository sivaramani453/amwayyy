variable "s3_bucket_name" {
  type = string
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
