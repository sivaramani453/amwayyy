variable depends_on {
  default = []
  type    = "list"
}

variable "function_name" {
  description = "Lambda function name"
  type        = "string"
}

variable "filename" {
  description = "Location of zip archive"
  type        = "string"
}

variable "handler" {
  description = "The executable file name value"
  type        = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "subnets" {
  type = "list"
}

variable "runtime" {
  description = "AWS Lambda runtime (go, python, node...)"
  type        = "string"
}

variable "timeout" {
  description = "Timeout for function. After this number of seconds amazon will force stop func execution "
  type        = "string"
  default     = "10"
}

variable "memory_amount" {
  description = "Memory amount on MB allocated for func. Must be >= 128"
  type        = "string"
  default     = "128"
}

variable "logs_retention" {
  description = "Number of days to store logs in cloudwatch"
  type        = "string"
  default     = "7"
}

variable "env_vars" {
  description = "environment variable to pass to aws lambda func"
  type        = "map"
  default     = {}
}

variable "principal" {
  type        = "string"
  description = "principal of lambda permission"
}

variable "arn" {
  type        = "string"
  description = "arn of resources allowed to trigger lambda func"
}

variable "statement_id" {
  type        = "string"
  description = "statement_id"
}
