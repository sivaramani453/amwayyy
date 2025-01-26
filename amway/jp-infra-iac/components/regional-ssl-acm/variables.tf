variable "domain_name" {
  type = string
}

variable "subject_alternative_names" {
  type = list(string)
}

variable "route53_zone" {
  type = string
}
