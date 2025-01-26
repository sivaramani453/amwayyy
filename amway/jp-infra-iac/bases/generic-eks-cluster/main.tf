###############################################################################
# Generic EKS Cluster                                                         #
#                                                                             #
# This creates an EKS cluster with one or more node groups, and               #
# an IAM role.                                                                #
#                                                                             #
###############################################################################

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
      configuration_aliases = [
        aws,
        aws.oidc_creator
      ]
    }
  }
}

module "eks_iam_role" {
  source        = "../../components/iam-role-with-policy"
  iam_role_name = "${var.eks_cluster_config.name}-eks-"
  default_principals = [
    "eks.amazonaws.com"
  ]
  aws_principals = []

  iam_policy_arns = concat(
    var.eks_cluster_config.policy_arns,
    var.eks_default_policy_arns
  )
}

module "eks_cluster" {
  source             = "../../components/eks"
  name               = var.eks_cluster_config.name
  eks_version        = var.eks_cluster_config.version
  vpc_id             = var.eks_cluster_config.vpc_id
  subnet_ids         = var.eks_cluster_config.subnet_ids
  security_group_ids = var.eks_cluster_config.security_group_ids
  eks_role_arn       = module.eks_iam_role.iam_role.arn
  default_tags       = var.default_tags
  eks_extra_tags     = var.eks_extra_tags
  node_groups        = var.node_groups
}

module "eks_cluster_oidc_provider" {
  source = "../../components/iam-openid-connect-provider"
  url    = "https://${module.eks_cluster.cluster.oidc_provider}"

  providers = {
    aws = aws.oidc_creator
  }

  depends_on = [
    module.eks_cluster
  ]
}

module "eks_infra_support_common_iam_role" {
  source        = "../../components/iam-role-with-policy"
  iam_role_name = "${var.eks_cluster_config.name}-eks-infra-role"
  default_principals = [
    "eks.amazonaws.com"
  ]
  federated_statements = [
    {
      "Effect" : "Allow",
      "Principal" : {
        "Federated" : "${module.eks_cluster_oidc_provider.oidc_provider.arn}"
      },
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Condition" : {
        "StringEquals" : {
          "${module.eks_cluster_oidc_provider.oidc_provider.url}:aud" : "sts.amazonaws.com"
        }
      }
    }
  ]

  iam_inline_policy_statements = var.eks_infra_support_iam_role_inline_policy

  depends_on = [
    module.eks_cluster_oidc_provider
  ]
}
