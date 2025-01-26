provider "aws" {
  region  = "${data.terraform_remote_state.core.region}"
  version = "~> 2.22.0"
}

locals {
  tags = "${map(
    "Service", "dev-debug",
    "Schedule", "daily_stop_21:00",
    "Terraform", "True",
  )}"

  volume_tags = "${map(
    "Name", "dev_${var.instance_name}",
    "Terraform", "True"
  )}"
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = ["EIA-Hybris-Trust"]
  }
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.21.0"

  name = "dev_${var.instance_name}"

  ami                    = "${var.ami}"
  instance_type          = "t3.xlarge"
  ebs_optimized          = "true"
  key_name               = "EPAM-SE"
  vpc_security_group_ids = ["${data.aws_security_group.main.id}"]
  subnet_id              = "${data.terraform_remote_state.core.subnet.dev_debug.id}"
  cpu_credits            = "unlimited"

  root_block_device = [{
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = true
  }]

  tags = "${merge(local.tags, var.custom_tags_instance, var.custom_tags_common)}"

  volume_tags = "${merge(local.volume_tags, var.custom_tags_volume, var.custom_tags_common)}"
}

resource "aws_volume_attachment" "this_ec2_db" {
  device_name = "/dev/sdg"
  volume_id   = "${aws_ebs_volume.db.id}"
  instance_id = "${module.ec2-instance.id[0]}"

  depends_on = ["aws_volume_attachment.this_ec2_media"]
}

resource "aws_ebs_volume" "db" {
  availability_zone = "${module.ec2-instance.availability_zone[0]}"
  snapshot_id       = "${var.db_volume_snapshot}"
  type              = "gp2"
  tags              = "${merge(local.volume_tags, var.custom_tags_volume, var.custom_tags_common)}"
}

resource "aws_volume_attachment" "this_ec2_media" {
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.media.id}"
  instance_id = "${module.ec2-instance.id[0]}"
}

resource "aws_ebs_volume" "media" {
  availability_zone = "${module.ec2-instance.availability_zone[0]}"
  snapshot_id       = "${var.media_volume_snapshot}"
  type              = "gp2"
  tags              = "${merge(local.volume_tags, var.custom_tags_volume, var.custom_tags_common)}"
}
