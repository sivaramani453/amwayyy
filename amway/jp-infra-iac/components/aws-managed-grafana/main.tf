module "amg_iam_role" {
  source                       = "../../components/iam-role-with-policy"
  iam_role_name                = "${var.workspace_name}-amg-"
  default_principals           = ["grafana.amazonaws.com"]
  iam_inline_policy_statements = var.amg_role_inline_policy
}

resource "aws_grafana_workspace" "grafana" {
  name                     = var.workspace_name
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["SAML"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = module.amg_iam_role.iam_role.arn
  data_sources             = var.data_sources

  network_access_control {
    prefix_list_ids = ["pl-00cec6c1791d11b29"]
    vpce_ids        = ["vpce-255ab84c"]
  }

  vpc_configuration {
    subnet_ids         = ["subnet-0dc805700ea636b09", "subnet-0e76b5e1a064b7500"]
    security_group_ids = ["sg-3b89765f", "sg-57395a33"]
  }

  depends_on = [module.amg_iam_role]
}



resource "aws_grafana_workspace_saml_configuration" "grafana_saml" {
  role_assertion     = var.role_assertion
  editor_role_values = var.editor_role_values
  admin_role_values  = var.admin_role_values
  idp_metadata_url   = var.idp_metadata_url
  workspace_id       = aws_grafana_workspace.grafana.id
  depends_on         = [aws_grafana_workspace.grafana]
}

output "grafana_url" {
  value = aws_grafana_workspace.grafana.endpoint
}

output "grafana_role_arn" {
  value = aws_grafana_workspace.grafana.role_arn
}
