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
  default     = "support-dev,support-rel,dev-rel,support-hotfix"
}

# variable "teams_eu_channel" {
#   default = "https://outlook.office.com/webhook/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/786d6a8a5df3456481c0dcdf5276cfb9/d2e32b29-36a7-4fb2-876f-377832641970"
# }

variable "teams_eu_channel" {
  default = "https://epam.webhook.office.com/webhookb2/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/628cd7a8bdd34c5da20e4714ecac7c31/ddd52314-da27-45e9-a3ca-d22551bfcec4"
}
