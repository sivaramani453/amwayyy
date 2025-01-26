locals {
  amway_application_id {
    default = "None"
    ru      = "APP3150571"
    eu      = "APP1433689"
  }

  amway_common_tags {
    Name          = "ci-update-snapshot-${terraform.workspace}"
    Terraform     = "True"
    Environment   = "DEV"
    ApplicationID = "${lookup(local.amway_application_id, replace(terraform.workspace, "/(?:.*)(eu|ru)(?:.*)/", "$1"), local.amway_application_id["default"])}"
  }

  amway_ec2_specific_tags = {
    Schedule           = "running"
    DataClassification = "Internal"
    SEC-INFRA-13       = "Appliance"
    SEC-INFRA-14       = "MSP"
  }

  amway_ebs_specific_tags {
    DataClassification = "Internal"
  }
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "instance_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["CI-SPOT-PR*"]
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
  version = "~> 1.0"

  name                   = "ci-update-snapshot-${terraform.workspace}"
  ami                    = "${data.aws_ami.instance_ami.id}"
  instance_type          = "t3a.large"
  ebs_optimized          = "true"
  key_name               = "EPAM-SE"
  vpc_security_group_ids = ["${data.aws_security_group.main.id}"]
  subnet_id              = "${data.terraform_remote_state.core.subnet.dev_debug.id}"
  cpu_credits            = "unlimited"

  root_block_device = [{
    volume_type           = "gp2"
    volume_size           = "200"
    delete_on_termination = true
  }]

  tags        = "${merge(local.amway_common_tags, local.amway_ec2_specific_tags)}"
  volume_tags = "${merge(local.amway_common_tags, local.amway_ebs_specific_tags)}"
}

resource "aws_volume_attachment" "this_ec2_env_media" {
  count       = "${var.is_env_media ? 1 : 0}"
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.env_media.id}"
  instance_id = "${module.ec2-instance.id[0]}"

  depends_on = ["aws_volume_attachment.this_ec2_env_db"]
}

resource "aws_ebs_volume" "env_media" {
  count             = "${var.is_env_media ? 1 : 0}"
  availability_zone = "${module.ec2-instance.availability_zone[0]}"
  snapshot_id       = "${var.env_media_volume_snapshot}"
  type              = "gp2"
  tags              = "${merge(local.amway_common_tags, local.amway_ebs_specific_tags)}"
}

resource "aws_volume_attachment" "this_ec2_env_db" {
  count       = "${var.is_env ? 1 : 0}"
  device_name = "/dev/sdg"
  volume_id   = "${aws_ebs_volume.env_db.id}"
  instance_id = "${module.ec2-instance.id[0]}"

  depends_on = ["aws_volume_attachment.this_ec2_ci_db"]
}

resource "aws_ebs_volume" "env_db" {
  count             = "${var.is_env ? 1 : 0}"
  availability_zone = "${module.ec2-instance.availability_zone[0]}"
  snapshot_id       = "${var.env_db_volume_snapshot}"
  type              = "gp2"
  tags              = "${merge(local.amway_common_tags, local.amway_ebs_specific_tags)}"
}

resource "aws_volume_attachment" "this_ec2_ci_db" {
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.ci_db.id}"
  instance_id = "${module.ec2-instance.id[0]}"
}

resource "aws_ebs_volume" "ci_db" {
  availability_zone = "${module.ec2-instance.availability_zone[0]}"
  snapshot_id       = "${var.ci_db_volume_snapshot}"
  type              = "gp2"
  tags              = "${merge(local.amway_common_tags, local.amway_ebs_specific_tags)}"
}
