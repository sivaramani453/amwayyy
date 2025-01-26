locals {
  core_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_b_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_c_id,
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  route53_zone_name = "hybris.eu.eia.amway.net"

  amway_common_tags = {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }

  amway_ec2_tags = {
    ITAM-SAM           = "MSP"
    DataClassification = "Internal"
    SEC-INFRA-13       = "Appliance"
    SEC-INFRA-14       = "MSP"
    Schedule           = "running"
  }

  amway_data_tags = {
    DataClassification = "Internal"
  }
}

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

data "aws_ami" "docker_host_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["docker-host*"]
  }
}


module "docker_host_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${terraform.workspace}-sg"
  description = "Security group for the docker host"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["ssh-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

module "docker_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "${terraform.workspace}-node"
  instance_count = length(local.core_subnet_ids)

  ami                         = data.aws_ami.docker_host_ami.id
  instance_type               = "t3.xlarge"
  key_name                    = data.terraform_remote_state.core.outputs.frankfurt_ssh_key
  vpc_security_group_ids      = [module.docker_host_sg.this_security_group_id]
  subnet_ids                  = local.core_subnet_ids
  iam_instance_profile        = aws_iam_instance_profile.docker_host_iam_profile.name
  associate_public_ip_address = false
  source_dest_check           = true
  ebs_optimized               = true
  monitoring                  = false

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "120"
      delete_on_termination = true
    },
  ]

  tags        = merge(local.amway_common_tags, local.amway_ec2_tags)
  volume_tags = merge(local.amway_common_tags, local.amway_data_tags)
}

resource "aws_route53_record" "docker_host_urls" {
  count   = length(local.core_subnet_ids)
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "${terraform.workspace}-${count.index}.${local.route53_zone_name}"
  ttl     = "300"
  type    = "A"

  records = [element(module.docker_host.private_ip, count.index)]
}
