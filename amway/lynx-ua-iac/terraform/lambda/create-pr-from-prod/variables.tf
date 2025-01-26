variable "eu_code_repo" {
  default = "lynx"
}

variable "ru_code_repo" {
  default = "lynx-ru"
}

variable "eu_config_repo" {
  default = "lynx-config"
}

variable "ru_config_repo" {
  default = "lynx-ru-config"
}

variable "git_token" {
  description = "Github API Token"
  type        = "string"
}

variable "sha_lynx" {
  description = "Last commit sha for prod branch (lynx)"
  type        = "string"
}

variable "sha_lynx_conf" {
  description = "Last commit sha for prod branch (lynx-config)"
  type        = "string"
}

variable "git_eu_branches" {
  description = "Commaseparated list of branches that should be updated"
  default     = "support-dev,support-rel,dev-rel,support-hotfix"
}

variable "git_ru_branches" {
  description = "Commaseparated list of branches that should be updated"
  default     = "support-rel,support-hotfix,support-dev,dev-rel"
}

variable "teams_eu_channel" {
  default = "https://outlook.office.com/webhook/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/786d6a8a5df3456481c0dcdf5276cfb9/d2e32b29-36a7-4fb2-876f-377832641970"
}

variable "teams_ru_channel" {
  default = "https://outlook.office.com/webhook/638d1d11-7735-48d0-8e7f-5d4527cd29e2@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/0399805363df423ea6721ee04baa18e7/d2e32b29-36a7-4fb2-876f-377832641970"
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
