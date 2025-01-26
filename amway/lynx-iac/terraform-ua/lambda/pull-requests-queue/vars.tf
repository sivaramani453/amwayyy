variable "dynamodb_table" {
  description = "Dynamodb table to store some prs metadata"
  default     = "pull_requests_queue"
}

variable "log_function_name" {
  description = "Lambda function name that will be used to deliver logs to ELK"
  default     = "SendLogsToElasticsearch"
}

variable "skype_secret" {
  type = "string"
}

variable "git_eu_token" {
  type = "string"
}

variable "git_ru_token" {
  type = "string"
}

variable "teams_eu_secret" {
  type = "string"
}

variable "teams_ru_secret" {
  type = "string"
}

variable "custom_tags_common" {
  description = "Amway custom tags"
  type        = "map"

  default = {
    Terraform     = "true"
    ApplicationID = "APP3151110"
    Environment   = "qa"
  }
}
