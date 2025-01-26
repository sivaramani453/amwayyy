resource "aws_instance" "be_nodes" {
  count                       = "${var.ec2_be_instance_count}"
  ami                         = "${data.aws_ami.env_ami.id}"
  iam_instance_profile        = "${var.ec2_instance_iam_profile}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_be_instance_type}"
  user_data                   = "${data.template_file.nodes_user_data.rendered}"
  monitoring                  = false
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.be_nodes_sg.this_security_group_id}"]
  subnet_id                   = "${element(local.env_subnet_ids, count.index)}"
  source_dest_check           = true
  private_ip                  = "${element(local.be_nodes_ips, count.index)}"
#  key_name                    = "ansible_rsa"

  root_block_device = [
    {
      volume_type           = "${var.root_volume_type}"
      volume_size           = "${var.root_volume_size}"
      delete_on_termination = true
    },
  ]

  tags = "${merge(map("Name", "${terraform.workspace}-BE${count.index + 1}"), local.be_tags, local.custom_tags["${terraform.workspace}"])}"
}

resource "aws_volume_attachment" "media_attachment" {
  device_name = "${var.media_volume_device_name}"
  volume_id   = "${data.aws_ebs_volume.media_volume.id}"
  instance_id = "${element(aws_instance.be_nodes.*.id, 1)}"
}

resource "aws_volume_attachment" "db_attachment" {
  device_name = "${var.db_volume_device_name}"
  volume_id   = "${data.aws_ebs_volume.db_volume.id}"
  instance_id = "${element(aws_instance.be_nodes.*.id, 1)}"
  depends_on  = ["aws_volume_attachment.media_attachment"]
}

resource "aws_instance" "fe_nodes" {
  count                       = "${var.ec2_fe_instance_count}"
  ami                         = "${data.aws_ami.env_ami.id}"
  iam_instance_profile        = "${var.ec2_instance_iam_profile}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_fe_instance_type}"
  user_data                   = "${data.template_file.nodes_user_data.rendered}"
  monitoring                  = false
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.fe_nodes_sg.this_security_group_id}"]
  subnet_id                   = "${element(local.env_subnet_ids, count.index)}"
  source_dest_check           = true
  private_ip                  = "${element(local.fe_nodes_ips, count.index)}"

  root_block_device = [
    {
      volume_type           = "${var.root_volume_type}"
      volume_size           = "${var.root_volume_size}"
      delete_on_termination = true
    },
  ]

  tags = "${merge(map("Name", "${terraform.workspace}-FE${count.index + 1}"), local.fe_tags, local.custom_tags["${terraform.workspace}"])}"
}
