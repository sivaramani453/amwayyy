variable "iam_policy_arns" {
  type        = list(string)
  description = "(Optional) list of IAM policy ARNs to add to the IAM role"
  default     = []
}

variable "iam_inline_policy_statements" {
  type        = list(any)
  description = "(Optional) list of IAM policy ARNs to add to the IAM role"
  default     = []
}

variable "default_principals" {
  type        = list(any)
  description = "Principals allowed to assume this role"
  default     = []
}

variable "service_principals" {
  type        = list(any)
  description = "Principals allowed to assume this role"
  default     = []
}

variable "aws_principals" {
  type        = list(any)
  description = "Principals allowed to assume this role"
  default     = []
}

variable "federated_statements" {
  type        = list(any)
  description = "Principals allowed to assume this role"
  default     = []
}

variable "iam_role_name" {
  type        = string
  description = "Name prefix for the IAM role"
}
