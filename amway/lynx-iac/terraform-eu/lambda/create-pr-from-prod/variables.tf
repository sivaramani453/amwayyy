variable "eu_code_repo" {
  default = "lynx"
}

variable "eu_config_repo" {
  default = "lynx-config"
}

variable "git_token" {
  description = "Github API Token"
  type        = string
}

variable "sha_lynx" {
  description = "Last commit sha for prod branch (lynx)"
  type        = string
}

variable "sha_lynx_conf" {
  description = "Last commit sha for prod branch (lynx-config)"
  type        = string
}

variable "git_eu_branches" {
  description = "Commaseparated list of branches that should be updated"
  default     = "main,release-patch,dev-rel,support-hotfix"
}

# variable "teams_eu_channel" {
#   default = "https://outlook.office.com/webhook/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/786d6a8a5df3456481c0dcdf5276cfb9/d2e32b29-36a7-4fb2-876f-377832641970"
# }

variable "teams_eu_channel" {
  default = "https://amwaycorp.webhook.office.com/webhookb2/c5fd6c30-9de7-42d4-84ec-8c694d0a822b@38c3fde4-197b-47b9-9500-769f547df698/IncomingWebhook/0f8cbd5863984f1f8af9d835adc596dd/c49d38bb-58f8-49f9-8371-2b0af7b2879b"
}
