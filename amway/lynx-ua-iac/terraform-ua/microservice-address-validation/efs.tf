resource "aws_efs_file_system" "efs_address_validation_fs" {
  tags = merge(map("Name", "${terraform.workspace}-efs"), local.amway_common_tags, local.amway_efs_specific_tags)
}

resource "aws_efs_mount_target" "efs_address_validation_mt" {
  count          = length(data.terraform_remote_state.core.outputs.infra_64_subnets)
  file_system_id = aws_efs_file_system.efs_address_validation_fs.id
  subnet_id      = element(data.terraform_remote_state.core.outputs.infra_64_subnets, count.index)

  security_groups = [
    module.efs_sg.security_group_id,
  ]
}

resource "aws_efs_access_point" "efs_address_validation_ap" {
  file_system_id = aws_efs_file_system.efs_address_validation_fs.id

  root_directory {
    path = "/"
  }

  posix_user {
    gid = 1001
    uid = 997
  }

  tags = merge(map("Name", "${terraform.workspace}-efs"), local.amway_common_tags, local.amway_efs_specific_tags)
}