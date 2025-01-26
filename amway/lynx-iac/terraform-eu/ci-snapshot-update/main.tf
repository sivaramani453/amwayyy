data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
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

module "es2_instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "ci-update-snapshot-${terraform.workspace}-sg"
  description = "Security group for the CI Update snapshot machine"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["ssh-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name = "ci-update-snapshot-${terraform.workspace}"

  ami                         = data.aws_ami.instance_ami.id
  instance_type               = "t3.xlarge"
  key_name                    = data.terraform_remote_state.core.outputs.frankfurt_ssh_key
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_iam_profile.name
  vpc_security_group_ids      = [module.es2_instance_sg.this_security_group_id]
  subnet_id                   = element(local.ci_subnet_ids, 0)
  associate_public_ip_address = false
  source_dest_check           = true
  ebs_optimized               = true
  monitoring                  = false

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "200"
      delete_on_termination = true
    },
  ]

  tags        = merge(local.amway_common_tags, local.amway_ec2_tags)
  volume_tags = merge(local.amway_common_tags, local.amway_data_tags)
}

resource "aws_volume_attachment" "this_ec2_ci_db" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ci_db.id
  instance_id = module.ec2_instance.id[0]
}

resource "aws_ebs_volume" "ci_db" {
  availability_zone = module.ec2_instance.availability_zone[0]
  snapshot_id       = var.ci_db_volume_snapshot
  type              = "gp2"
  tags              = merge({ "Name" = "ci-update-snapshot-${terraform.workspace}-db" }, local.amway_common_tags, local.amway_data_tags)
}

resource "aws_volume_attachment" "this_ec2_env_db" {
  count       = var.is_env ? 1 : 0
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.env_db[count.index].id
  instance_id = module.ec2_instance.id[0]

  depends_on = [aws_volume_attachment.this_ec2_ci_db]
}

resource "aws_ebs_volume" "env_db" {
  count             = var.is_env ? 1 : 0
  availability_zone = module.ec2_instance.availability_zone[0]
  snapshot_id       = var.env_db_volume_snapshot
  type              = "gp2"
  tags              = merge({ "Name" = "ci-update-snapshot-${terraform.workspace}-db" }, local.amway_common_tags, local.amway_data_tags)
}

resource "aws_volume_attachment" "this_ec2_env_media" {
  count       = var.is_env_media ? 1 : 0
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.env_media[count.index].id
  instance_id = module.ec2_instance.id[0]

  depends_on = [aws_volume_attachment.this_ec2_env_db]
}

resource "aws_ebs_volume" "env_media" {
  count             = var.is_env_media ? 1 : 0
  availability_zone = module.ec2_instance.availability_zone[0]
  snapshot_id       = var.env_media_volume_snapshot
  type              = "gp2"
  tags              = merge({ "Name" = "ci-update-snapshot-${terraform.workspace}-media" }, local.amway_common_tags, local.amway_data_tags)
}
