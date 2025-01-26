module "ec2_product_labeling_postgresql_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 1.0"

  name           = "${terraform.workspace}-postgresql-instance"
  instance_count = "1"

  ami                    = "ami-0173b4f5e2969a95b"
  ebs_optimized          = true
  instance_type          = "t3.large"
  key_name               = "${data.terraform_remote_state.core.frankfurt.ssh_key}"
  monitoring             = true
  vpc_security_group_ids = ["${module.product_labeling_postgresql_instance_sg.this_security_group_id}"]
  subnet_ids             = "${local.kube_subnet_ids}"

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = 20
      delete_on_termination = true
    },
  ]

  tags        = "${merge(map("Name", "${terraform.workspace}-postgresql"), local.amway_common_tags, local.amway_ec2_specific_tags)}"
  volume_tags = "${merge(map("Name", "${terraform.workspace}-postgresql"), local.amway_common_tags, local.amway_ebs_specific_tags)}"
}

resource "aws_ebs_volume" "db" {
  availability_zone = "${module.ec2_product_labeling_postgresql_instance.availability_zone[0]}"
  type              = "gp2"
  size              = 100
  tags              = "${merge(map("Name", "${terraform.workspace}-postgresql"), local.amway_common_tags, local.amway_ebs_specific_tags)}"
}

resource "aws_volume_attachment" "this_ec2_db" {
  device_name = "/dev/sdg"
  volume_id   = "${aws_ebs_volume.db.id}"
  instance_id = "${module.ec2_product_labeling_postgresql_instance.id[0]}"
}

resource "aws_efs_file_system" "efs_product_labeling_fs" {
  tags = "${merge(map("Name", "${terraform.workspace}-postgresql"), local.amway_common_tags, local.amway_efs_specific_tags)}"
}

resource "aws_efs_mount_target" "efs_product_labeling_mt" {
  count          = "${length(local.kube_subnet_ids)}"
  file_system_id = "${aws_efs_file_system.efs_product_labeling_fs.id}"
  subnet_id      = "${element(local.kube_subnet_ids, count.index)}"

  security_groups = [
    "${module.efs_sg.this_security_group_id}",
  ]
}

resource "null_resource" "provisioning_the_postgresql_instance" {
  depends_on = ["aws_route53_record.product_labeling_postgresql_url", "aws_volume_attachment.this_ec2_db"]

  provisioner "local-exec" {
    on_failure = "fail"

    command = <<EOT
    echo "[postgresql]" > ./ansible/hosts;
    echo "${aws_route53_record.product_labeling_postgresql_url.name}" >> ./ansible/hosts;
    ansible-galaxy install -r ./ansible/requirements.yml -p ./ansible/roles/ -f;
    ansible-playbook ./ansible/bootstrap.yml -u centos -i ./ansible/hosts --extra-vars "archive_efs_mountpoint_src='${aws_route53_record.efs_urls.name}' docker_registry_username='${var.docker_registry_user}' docker_registry_password='${var.docker_registry_password}'"  --private-key="$PATH_TO_SSH_KEY";

EOT

    environment = {
      ANSIBLE_SSH_RETRIES       = "10"
      ANSIBLE_HOST_KEY_CHECKING = "False"
      PATH_TO_SSH_KEY           = "${var.path_to_ssh_key}"
    }
  }
}
