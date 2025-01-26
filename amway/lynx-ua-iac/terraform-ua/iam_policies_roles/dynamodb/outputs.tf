output "rendered_policy" {
  value = data.aws_iam_policy_document.dynamodb_policy_mcrsrv_template.json
}
