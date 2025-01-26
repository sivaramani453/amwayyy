variable "log_function_name" {
  description = "existing func that sends logs to elk stack"
  default     = "SendLogsToElasticsearch"
}

variable "SECRET" {
  description = "github webhook secret vault path: kv/github/amway/lynx_webhook_secret"
  type        = "string"
}

variable "TOKEN" {
  description = "github root account static token vault path: kv/github/amway/git_admin_user_2 field=token_full_access"
  type        = "string"
}

variable "BAMBOO_USER" {
  description = "bamboo user"
  type        = "string"
  default     = "builduser"
}

variable "BAMBOO_PASSWORD" {
  description = "bamboo password vault path: kv/bamboo/builduser"
  type        = "string"
}

variable "BAMBOO_URL" {
  description = "bamboo api endpoint addr"
  type        = "string"
  default     = "https://amway-prod.tt.com.pl/bamboo/rest/api/latest/queue/"
}

variable "SKYPE_SECRET" {
  description = "skype secret vault path: kv/bots/devops_skype_bot"
  type        = "string"
}

variable "CHAT_ID" {
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
