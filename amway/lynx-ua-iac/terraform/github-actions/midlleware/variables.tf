variable "log_function_name" {
  description = "existing func that sends logs to elk stack"
  default     = "SendLogsToElasticsearch"
}

variable "github_webhook_secret" {
  description = "github webhook secret vault path: kv/github/amway/lynx_webhook_secret"
  type        = "string"
}

variable "github_token" {
  description = "github root account static token vault path: kv/github/amway/git_admin_user_2 field=token_full_access"
  type        = "string"
}

variable "skype_secret" {
  description = "skype secret vault path: kv/bots/devops_skype_bot"
  type        = "string"
}

variable "skype_chat_id" {
  description = "chat id to send errors, default is devops chat"
  type        = "string"
  default     = "aweu_eia_system_engineering"
}

variable "custom_tags_common" {
  description = "Amway custom tags"
  type        = "map"

  default = {
    Terraform     = "true"
    ApplicationID = "APP3151110"
    Environment   = "test"
  }
}
