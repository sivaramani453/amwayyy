resource "aws_instance" "be_nodes" {

  count                       = var.ec2_be_instance_count
  ami                         = data.aws_ami.env_ami.id
  instance_type               = var.ec2_be_instance_type
  user_data                   = data.template_file.nodes_user_data.rendered
  vpc_security_group_ids      = [module.be_nodes_sg.this_security_group_id]
  subnet_id                   = element(local.env_subnet_ids, count.index)
  iam_instance_profile        = aws_iam_instance_profile.node_iam_profile.name
  associate_public_ip_address = false
  source_dest_check           = true
  ebs_optimized               = true
  monitoring                  = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 15
    delete_on_termination = true
  }

  #volume_tags is missing because it overwrites db and media tag names for attached volumes and the next redeployment will fail.
  #see data section, in the future, we need to change this behavior.

  tags = merge({ "Name" = "${terraform.workspace}-BE${count.index + 1}" }, local.be_tags, local.amway_common_tags, local.amway_ec2_tags)
}

resource "aws_volume_attachment" "media_attachment" {
  device_name = var.media_volume_device_name
  volume_id   = data.aws_ebs_volume.media_volume.id
  instance_id = element(aws_instance.be_nodes.*.id, 1)
}

resource "aws_volume_attachment" "db_attachment" {
  device_name = var.db_volume_device_name
  volume_id   = data.aws_ebs_volume.db_volume.id
  instance_id = element(aws_instance.be_nodes.*.id, 1)
  depends_on  = [aws_volume_attachment.media_attachment]
}

resource "aws_instance" "fe_nodes" {

  count                       = var.ec2_fe_instance_count
  ami                         = data.aws_ami.env_ami.id
  instance_type               = var.ec2_fe_instance_type
  user_data                   = data.template_file.nodes_user_data.rendered
  vpc_security_group_ids      = [module.fe_nodes_sg.this_security_group_id]
  subnet_id                   = element(local.env_subnet_ids, count.index)
  iam_instance_profile        = aws_iam_instance_profile.node_iam_profile.name
  associate_public_ip_address = false
  source_dest_check           = true
  ebs_optimized               = true
  monitoring                  = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 15
    delete_on_termination = true
  }

  #volume_tags is missing because it overwrites db and media tag names for attached volumes and the next redeployment will fail.
  #see data section, in the future, we need to change this behavior.

  tags = merge({ "Name" = "${terraform.workspace}-FE${count.index + 1}" }, local.fe_tags, local.amway_common_tags, local.amway_ec2_tags)
}
