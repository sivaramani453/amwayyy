module "simple-iam-role-with-policy" {
  source                       = "../../components/iam-role-with-policy-fixed-name"
  iam_role_name                = var.iam_role_name
  default_principals           = var.default_principals
  aws_principals               = var.aws_principals
  federated_statements         = var.federated_statements
  iam_policy_arns              = var.iam_policy_arns
  iam_inline_policy_statements = var.iam_inline_policy_statements
}
