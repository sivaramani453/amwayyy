variable "runner_version" {
  description = "GitLab runner version"
  default     = "11.11.3"
}

variable "runner_token" {
  description = "Token for runner to auth"
}

variable "runner_tags" {
  description = "List of tags to assign to runner"
  type        = "list"
  default     = ["prod-frankfurt-runner"]
}

variable "instance_type" {
  description = "Instance type"
  default     = "t3.medium"
}

variable "spot_price" {
  description = "Spot price bid"
  default     = "0.1"
}

variable "runners_name" {
  description = "Runners name"
  default     = "prod-frankfurt-runner"
}

variable "gitlab_url" {
  description = "gitlab URL"
  default     = "https://gitlab.com/"
}

variable "runners_off_peak_periods" {
  description = "runners off peak periods"
  default     = "* * * * * sat,sun *"
}
