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
    values = ["${terraform.workspace}-db"]
  }
}

data "aws_ebs_volume" "media_volume" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["${terraform.workspace}-media"]
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

data "template_file" "inventory" {
  depends_on = ["aws_instance.be_nodes", "aws_instance.fe_nodes"]
  template   = "${file("${path.module}/files/hosts.ini.tpl")}"

  vars = {
    fe1_instance_fqdn = "${element(aws_route53_record.fe_nodes_urls.*.name, 0)}"
    fe1_instance_id   = "${element(aws_instance.be_nodes.*.id, 0)}"
    fe2_instance_fqdn = "${element(aws_route53_record.fe_nodes_urls.*.name, 1)}"
    fe2_instance_id   = "${element(aws_instance.be_nodes.*.id, 1)}"
    be1_instance_fqdn = "${element(aws_route53_record.be_nodes_urls.*.name, 0)}"
    be1_instance_id   = "${element(aws_instance.fe_nodes.*.id, 0)}"
    be2_instance_fqdn = "${element(aws_route53_record.be_nodes_urls.*.name, 1)}"
    be2_instance_id   = "${element(aws_instance.fe_nodes.*.id, 1)}"
  }
}

data "template_file" "nodes_user_data" {
  template = "${file("${path.module}/files/userdata.tpl")}"
}
