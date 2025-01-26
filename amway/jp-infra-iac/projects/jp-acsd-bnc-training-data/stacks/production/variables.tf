variable "default_tags" {
  type = map(string)
  default = {
    ApplicationID = "APPXXXXXX",
    Contact       = "dayu_you@amway.com",
    Project       = "JP-ACSD-BNC-TRAINING-DATA",
    Country       = "Japan",
    Environment   = "PROD"
  }
}

variable "iam_role_name" {
  description = "Name for the IAM role"
  type        = string
  default     = "jp-prod-bnc-eks-microservice-iam-role"
}

variable "default_principals" {
  type        = list(any)
  description = "Principals allowed to assume this role"
  default     = ["eks.amazonaws.com"]
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

variable "iam_policy_arns" {
  description = "Default policies to add to the EKS IAM role"
  type        = list(any)
  default = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]
}

variable "federated_statements" {
  type        = list(any)
  description = "Principals allowed to assume this role"
  default = [
    {
      "Effect" : "Allow",
      "Principal" : {
        "Federated" : "arn:aws:iam::618163872161:oidc-provider/oidc.eks.ap-northeast-1.amazonaws.com/id/AE1D49B726963FEC46091E407B6BFC46"
      },
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Condition" : {
        "StringEquals" : {
          "oidc.eks.ap-northeast-1.amazonaws.com/id/AE1D49B726963FEC46091E407B6BFC46:aud" : "sts.amazonaws.com"
        }
      }
    }
  ]
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
