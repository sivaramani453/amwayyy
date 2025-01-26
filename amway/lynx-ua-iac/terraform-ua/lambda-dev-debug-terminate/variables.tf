variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "env_vars" {
  description = "Environment vars to use inside lambda func (this function doesn't use any, so put dummy)"
  type        = "map"

  default = {
    Terraform = "True"
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
