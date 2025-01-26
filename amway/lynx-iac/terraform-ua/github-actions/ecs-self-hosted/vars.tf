variable "cluster_name" {
  type    = "string"
  default = "ga-dev-cluster"
}

variable "cluster_max_size" {
  type    = "string"
  default = "5"
}

variable "instance_type" {
  type    = "string"
  default = "t3.medium"
}

variable "additional_instance_type_1" {
  type    = "string"
  default = "t3.medium"
}

variable "additional_instance_type_2" {
  type    = "string"
  default = "t3.large"
}

variable "volume_size" {
  type    = "string"
  default = "40"
}

variable "key_pair_name" {
  type    = "string"
  default = "EPAM-SE"
}

variable "git_token" {
  type = "string"
}

/*variable "git_token_epam" {
  type = "string"
}*/

