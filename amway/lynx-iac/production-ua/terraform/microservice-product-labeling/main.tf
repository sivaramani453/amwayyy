resource "aws_instance" "pl_nodes" {
  count                       = "${var.ec2_pl_nodes_count}"
  ami                         = "${data.aws_ami.env_ami.id}"
  iam_instance_profile        = "${var.ec2_instance_iam_profile}"
  ebs_optimized               = true
  instance_type               = "${var.ec2_pl_nodes_instance_type}"
  user_data                   = "${data.template_file.nodes_user_data.rendered}"
  key_name                    = "${data.terraform_remote_state.core.frankfurt.ssh_key}"
  monitoring                  = false
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.pl_nodes_sg.this_security_group_id}"]
  subnet_id                   = "${element(local.kube_subnet_ids, count.index)}"
  source_dest_check           = true

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = "20"
      delete_on_termination = true
    },
  ]

  tags        = "${merge(map("Name", "${terraform.workspace}-node-${count.index + 1}"), local.amway_common_tags, local.amway_ec2_specific_tags)}"
  volume_tags = "${merge(map("Name", "${terraform.workspace}-node-${count.index + 1}"), local.amway_common_tags, local.amway_ebs_specific_tags)}"
}
