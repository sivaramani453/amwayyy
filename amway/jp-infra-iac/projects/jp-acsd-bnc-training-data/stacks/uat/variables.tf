variable "default_tags" {
  type = map(string)
  default = {
    ApplicationID = "APPXXXXXX",
    Contact       = "dayu_you@amway.com",
    Project       = "JP-ACSD-BNC-TRAINING-DATA",
    Country       = "Japan",
    Environment   = "DEV"
  }
}

variable "iam_role_name" {
  description = "Name for the IAM role"
  type        = string
  default     = "jp-uat-bnc-eks-microservice-iam-role"
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
        "Federated" : "arn:aws:iam::417642731771:oidc-provider/oidc.eks.ap-northeast-1.amazonaws.com/id/348C333BC86A0F0213B43D7C2E485E88"
      },
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Condition" : {
        "StringEquals" : {
          "oidc.eks.ap-northeast-1.amazonaws.com/id/348C333BC86A0F0213B43D7C2E485E88:aud" : "sts.amazonaws.com"
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
