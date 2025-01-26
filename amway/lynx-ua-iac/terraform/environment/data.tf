data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ebs_volume" "db_volume" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["${var.ec2_env_name}-db"]
  }
}

data "aws_ebs_volume" "media_volume" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["${var.ec2_env_name}-media"]
  }
}

data "aws_ami" "env_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["environment-${var.ec2_env_suffix}*"]
  }
}

data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = ["EIA-Hybris-Trust"]
  }
}

data "template_file" "inventory" {
  depends_on = ["aws_instance.backend_node_1", "aws_instance.backend_node_2", "aws_instance.frontend_node_1", "aws_instance.frontend_node_2"]
  template   = "${file("${path.module}/hosts.ini.tpl")}"

  vars = {
    fe1_instance_ip = "${aws_instance.frontend_node_1.private_ip}"
    fe1_instance_id = "${aws_instance.frontend_node_1.id}"
    fe2_instance_ip = "${aws_instance.frontend_node_2.private_ip}"
    fe2_instance_id = "${aws_instance.frontend_node_2.id}"
    be1_instance_ip = "${aws_instance.backend_node_1.private_ip}"
    be1_instance_id = "${aws_instance.backend_node_1.id}"
    be2_instance_ip = "${aws_instance.backend_node_2.private_ip}"
    be2_instance_id = "${aws_instance.backend_node_2.id}"
  }
}
