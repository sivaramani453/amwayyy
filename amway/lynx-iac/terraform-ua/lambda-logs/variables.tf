variable "region" {
  default = "eu-central-1"
}

variable "function_name" {
  description = "Lambda function name"
  type        = "string"
  default     = "SendLogsToElasticsearch"
}

variable "handlername" {
  description = "The executable file name value"
  type        = "string"
  default     = "log"
}

variable "timeout" {
  description = "Timeout for function. After this number of seconds amazon will force stop func execution "
  type        = "string"
  default     = "30"
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
  description = "Environment vars to use inside lambda func"
  type        = "map"

  default = {
    ELK_URL                     = "https://vpc-aws-elasticsearch-5unizluspnic6n5zudjomi7eam.eu-central-1.es.amazonaws.com"
    AlertManagerWebhook         = "aws-logs-alertmanager-webhook"
    GithubLynxMiddleware        = "aws-logs-middleware"
    GithubLynxConfigMiddleware  = "aws-logs-middleware-config"
    eia_coupons_db_qa_2         = "aws-eia-coupons-db-qa2"
    eia_coupons_db_test_2       = "aws-eia-coupons-db-test2"
    eia_customs_declaration_dev = "aws-eia-customs-declaration-dev"
  }
}

variable "custom_tags_common" {
  description = "Amway custom tags"
  type        = "map"

  default = {
    Terraform     = "true"
    ApplicationID = "APP3151110"
    Environment   = "dev"
  }
}
