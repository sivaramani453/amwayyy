module "resources" {
  source = "../../../../bases/acsd-batch-jobs-resources"

  iam_role_name     = var.iam_role_name
  s3_bucket_name    = var.s3_bucket_name
  oidc_statement    = var.oidc_statement
  dynamo_table_name = var.dynamo_table_name
}
