variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "table_prefix" {
  description = "Dynamodb Table prefix "
}

variable "policy_name" {
  description = "Policy name"
}

variable "role_name" {
  description = "Role name"
}
