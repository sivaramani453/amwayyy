# EKS cluster configuration
variable "eks_cluster_config" {
  description = "Configuration object for the EKS cluster"
  type = object({
    name                    = string
    version                 = string
    policy_arns             = list(string)
    automation_account_root = string
    vpc_id                  = string
    subnet_ids              = list(string)
    security_group_ids      = list(string)

    eks_auth_roles = list(object({
      rolearn  = string,
      username = string,
      groups   = list(string)
    }))

  })
}

variable "eks_extra_tags" {
  type    = map(string)
  default = {}
}

variable "eks_default_policy_arns" {
  description = "Default policies to add to the EKS IAM role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]
}

# Node groups configurations

variable "node_groups" {
  description = "Map of definition for each node group. See variables.tf for examples."
  type = map(object({
    name                            = string
    use_custom_launch_template      = optional(bool, true)
    use_name_prefix                 = optional(bool, true)
    launch_template_use_name_prefix = optional(bool, true)
    description                     = optional(string)
    subnet_ids                      = list(string)

    iam_role_name  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    instance_types = optional(list(string))
    capacity_type  = string
  }))
}

variable "default_tags" {
  type = map(string)
}

variable "eks_infra_support_iam_role_inline_policy" {
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = [
    {
      "Effect" : "Allow",
      "Action" : [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource" : [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource" : [
        "*"
      ]
    }
  ]
}


