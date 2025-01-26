variable "configmap_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "configmap_data" {
  type    = any
  default = null
}

variable "configmap_binary_data" {
  type    = any
  default = null
}
