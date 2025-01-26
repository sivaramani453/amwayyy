resource "aws_ssm_parameter" "commit_sha_lynx" {
  name  = "last-commit-sha-prod-lynx-${terraform.workspace}"
  type  = "String"
  value = "${var.sha_lynx}"
}

resource "aws_ssm_parameter" "commit_sha_lynx_conf" {
  name  = "last-commit-sha-prod-lynx-config-${terraform.workspace}"
  type  = "String"
  value = "${var.sha_lynx_conf}"
}
