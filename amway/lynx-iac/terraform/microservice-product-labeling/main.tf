resource "aws_instance" "pl_nodes" {
  count                       = "${var.ec2_pl_nodes_count}"
  ami                         = "${data.aws_ami.env_ami.id}"
  iam_instance_profile        = "${var.ec2_instance_iam_profile}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_pl_nodes_instance_type}"
  user_data                   = "${data.template_file.nodes_user_data.rendered}"
  monitoring                  = false
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.pl_nodes_sg.this_security_group_id}"]
  subnet_id                   = "${element(local.core_subnet_ids, count.index)}"
  source_dest_check           = true

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "20"
      delete_on_termination = true
    },
  ]

  tags = "${merge(map("Name", "${terraform.workspace}-node-${count.index + 1}"), local.pl_tags, local.custom_tags_common, local.custom_tags_specific)}"
}
