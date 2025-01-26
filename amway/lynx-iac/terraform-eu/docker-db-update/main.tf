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
    values = ["DOCKER-DB-UPDATE*"]
  }
}

module "es2_instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "docker-db-update-${var.branch_name}-sg"
  description = "Security group for the Docker DB Update"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["ssh-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name = "docker-db-update-${var.branch_name}"

  ami                         = data.aws_ami.instance_ami.id
  instance_type               = "t3.xlarge"
  key_name                    = data.terraform_remote_state.core.outputs.frankfurt_ssh_key
  vpc_security_group_ids      = [module.es2_instance_sg.this_security_group_id]
  subnet_id                   = element(local.ci_subnet_ids, 0)
  associate_public_ip_address = false
  source_dest_check           = true
  ebs_optimized               = true
  monitoring                  = false

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
  instance_id = module.ec2_instance.id[0]

  depends_on = [aws_volume_attachment.this_ec2_media]
}

resource "aws_ebs_volume" "db" {
  availability_zone = module.ec2_instance.availability_zone[0]
  snapshot_id       = var.db_volume_snapshot
  type              = "gp2"
  tags              = merge({ "Name" = "docker-db-update-${var.branch_name}-db" }, local.amway_common_tags, local.amway_data_tags)
}

resource "aws_volume_attachment" "this_ec2_media" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.media.id
  instance_id = module.ec2_instance.id[0]
}

resource "aws_ebs_volume" "media" {
  availability_zone = module.ec2_instance.availability_zone[0]
  snapshot_id       = var.media_volume_snapshot
  type              = "gp2"
  tags              = merge({ "Name" = "docker-db-update-${var.branch_name}-media" }, local.amway_common_tags, local.amway_data_tags)
}
