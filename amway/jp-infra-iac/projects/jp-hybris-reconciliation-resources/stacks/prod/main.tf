module "recon_resources" {
  source                = "../../../../bases/reconciliation-resources"
  iam_role_name         = var.iam_role_name
  s3_bucket_name        = var.s3_bucket_name
  oidc_statement        = var.oidc_statement
  s3_bucket_name_export = var.s3_bucket_name_export
}
