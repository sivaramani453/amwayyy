resource "aws_ssm_parameter" "ssm_branches" {
  count = "${length(local.branches_list[lower(terraform.workspace)])}"
  name  = "locked-${terraform.workspace}-${element(local.branches_list[terraform.workspace], count.index)}"
  type  = "String"
  value = "False"
}
