variable "namespace" {
  type = string
}

variable "name" {
  type = string
}

variable "type" {
  type    = string
  default = "Opaque"
}

variable "data" {
  type    = any
  default = {}
}
