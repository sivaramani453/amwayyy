variable "cluster_name" {
  type    = "string"
  default = "ga-pos-bos-cluster"
}

variable "cluster_max_size" {
  type    = "string"
  default = "5"
}

variable "instance_type" {
  type    = "string"
  default = "t3.2xlarge"
}

variable "volume_size" {
  type    = "string"
  default = "25"
}

variable "key_pair_name" {
  type    = "string"
  default = "EPAM-SE"
}

variable "git_token" {
  type = "string"
}
