module "bnc-eks-microservice-iam-role" {
  source                       = "../../../../bases/simple-iam-role-with-policy"
  iam_role_name                = var.iam_role_name
  default_principals           = var.default_principals
  federated_statements         = var.federated_statements
  iam_policy_arns              = var.iam_policy_arns
  iam_inline_policy_statements = var.iam_inline_policy_statements
}
