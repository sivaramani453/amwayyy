variable "github_webhook_secret" {
  description = "github webhook secret vault path: amway/github/amway/lynx_webhook_secret"
  type        = string
}

variable "github_token" {
  description = "github root account static token vault path: amway/github/amway/git_admin_user_4_enterprise field=token_full_access"
  type        = string
}

variable "skype_secret" {
  description = "skype secret vault path: amway/bots/devops_skype_bot"
  type        = string
}

variable "skype_chat_id" {
  description = "chat id to send errors, default is devops chat"
  type        = string
  default     = "aweu_eia_system_engineering"
}
