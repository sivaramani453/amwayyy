# Vault configuration file and userdata

locals {
  vault_cluster_subnets_ids = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}", "${data.terraform_remote_state.core.subnet.core_c.id}"]
}

data "template_file" "vault_user_data" {
  template = "${ file( "${path.module}/files/userdata.sh" ) }"

  vars {
    cluster_name              = "${var.vault_cluster_name}"
    region                    = "${var.region}"
    vault_lb_dns_name         = "${var.lb_dns_name}"
    vault_data_bucket_name    = "${aws_s3_bucket.vault_data.id}"
    vault_dynamodb_table_name = "${aws_dynamodb_table.vault_dynamodb_table.id}"
    vault_kms_seal_key_id     = "${aws_kms_key.vault_seal.key_id}"
  }
}

resource "aws_instance" "vault_node" {
  count                       = "${length(local.vault_cluster_subnets_ids)}"
  ami                         = "${data.aws_ami.vault_node_ami.id}"
  instance_type               = "${var.ec2_instance_type}"
  key_name                    = "${var.vault_ssh_key_name}"
  user_data                   = "${data.template_file.vault_user_data.rendered}"
  vpc_security_group_ids      = ["${aws_security_group.vault_cluster_sg_ec2.id}"]
  subnet_id                   = "${element(local.vault_cluster_subnets_ids, count.index)}"
  iam_instance_profile        = "${aws_iam_instance_profile.vault_iam_profile.name}"
  associate_public_ip_address = false
  source_dest_check           = true
  ebs_optimized               = true
  monitoring                  = false

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags = "${merge(map(
    "Name", "${var.vault_cluster_name}-${var.ec2_node_name}-${count.index}",
    "Schedule", "running"
     ), var.custom_tags_common, var.custom_tags_instance)}"
}
