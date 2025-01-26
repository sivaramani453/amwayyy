variable "iam_role_name" {
  description = "Fixed name for the IAM role"
  type        = string
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

variable "iam_policy_arns" {
  type        = list(any)
  description = "(Optional) list of IAM policy ARNs to add to the IAM role"
  default     = []
}

variable "iam_inline_policy_statements" {
  description = "(Optional) list of IAM policy ARNs to add to the IAM role"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = []
}
