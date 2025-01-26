variable "nlb_name" {
  type = string
}

variable "internal" {
  type = bool
}

variable "subnet_ids" {
  type = list(string)
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
