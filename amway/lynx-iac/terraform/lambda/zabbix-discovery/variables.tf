variable "zabbix_password" {
  description = "zabbix password"
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
