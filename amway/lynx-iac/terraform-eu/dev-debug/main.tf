data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "ec2_dev_debug" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name = "dev_${var.instance_name}"

  ami                         = var.ami
  instance_type               = "t3.xlarge"
  key_name                    = data.terraform_remote_state.core.outputs.frankfurt_ssh_key
  vpc_security_group_ids      = [module.es2_dev_debug_sg.this_security_group_id]
  subnet_id                   = element(local.ci_subnet_ids, 0)
  associate_public_ip_address = false
  source_dest_check           = true
  ebs_optimized               = true
  monitoring                  = false
  iam_instance_profile        = data.terraform_remote_state.core.outputs.dev_debug_iam_instance_profile

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "40"
      delete_on_termination = true
    },
  ]

  tags        = merge(local.amway_common_tags, local.amway_ec2_tags)
  volume_tags = merge(local.amway_common_tags, local.amway_data_tags)
}

resource "aws_volume_attachment" "this_ec2_db" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.db.id
  instance_id = module.ec2_dev_debug.id[0]

  depends_on = [aws_volume_attachment.this_ec2_media, module.ec2_dev_debug]
}

resource "aws_ebs_volume" "db" {
  availability_zone = module.ec2_dev_debug.availability_zone[0]
  snapshot_id       = var.db_volume_snapshot
  type              = "gp2"
  tags              = merge({ "Name" = "dev_${var.instance_name}-db" }, local.amway_common_tags, local.amway_data_tags)
  depends_on = [module.ec2_dev_debug]
}

resource "aws_volume_attachment" "this_ec2_media" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.media.id
  instance_id = module.ec2_dev_debug.id[0]
  depends_on = [module.ec2_dev_debug]
}

resource "aws_ebs_volume" "media" {
  depends_on = [module.ec2_dev_debug]
  availability_zone = module.ec2_dev_debug.availability_zone[0]
  snapshot_id       = var.media_volume_snapshot
  type              = "gp2"
  tags              = merge({ "Name" = "dev_${var.instance_name}-media" }, local.amway_common_tags, local.amway_data_tags)
}
