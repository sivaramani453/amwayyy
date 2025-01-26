variable "splunk_token" {
  type = string
}

variable "set_list" {
  type = map(string)

  default = {}
}
