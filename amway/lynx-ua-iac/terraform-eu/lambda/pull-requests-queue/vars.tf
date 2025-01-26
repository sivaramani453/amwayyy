variable "dynamodb_table" {
  description = "Dynamodb table to store some prs metadata"
  default     = "pull_requests_queue"
}

variable "skype_secret" {
  type = string
}

variable "git_eu_token" {
  type = string
}

variable "teams_eu_secret" {
  type = string
}
