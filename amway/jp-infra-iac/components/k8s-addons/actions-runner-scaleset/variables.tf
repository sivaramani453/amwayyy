variable "runner_version" {
  type = string
}

variable "github_auth_secret" {
  type = string
}

variable "github_config_url" {
  type = string
}

variable "min_runners" {
  type    = number
  default = 0
}

variable "max_runners" {
  type    = number
  default = 5
}

variable "runner_scale_set_name" {
  type = string
}

variable "runner_group" {
  type    = string
  default = ""
}

variable "runner_image" {
  type    = string
  default = "ghcr.io/actions/actions-runner:latest"
}

variable "custom_values" {
  type    = string
  default = null
}

variable "container_mode" {
  type    = string
  default = null
}
