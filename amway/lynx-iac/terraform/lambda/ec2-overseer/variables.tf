variable "MESSAGE_CHAT_PASSWORD" {
  description = "Skype secret vault path: kv/bots/devops_skype_bot"
  type        = "string"
}

variable "MESSAGE_SERVER_URL" {
  description = "Skype secret vault path: kv/bots/devops_skype_bot"
  type        = "string"
  default     = "https://touch.epm-esp.projects.epam.com/bot-esp/message"
}

variable "MESSAGE_CHAT_NAME" {
  description = "Chat id to send errors, default is devops chat"
  type        = "string"
  default     = "aweu_eia_system_engineering"
}

variable "RUN_LIMIT_SEC" {
  description = "Time in seconds to seek for running machines more than this span"
  type        = "string"
  default     = "86400"
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
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
