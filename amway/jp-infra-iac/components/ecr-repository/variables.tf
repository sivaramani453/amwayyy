variable "ecr_repo_name" {
  type = string
}

variable "ecr_repo_policy" {
  type    = any
  default = {}
}
