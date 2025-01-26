module "nexus_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.16.0"

  name           = "nexus-instance"
  instance_count = length(local.instance_subnets)

  ami                    = data.aws_ami.latest_nexus_ami.id
  instance_type          = "t3.large"
  iam_instance_profile   = aws_iam_instance_profile.nexus_iam_profile.name
  key_name               = data.terraform_remote_state.core.outputs.frankfurt_ssh_key
  monitoring             = true
  vpc_security_group_ids = [module.nexus_ec2_sg.this_security_group_id]
  subnet_ids             = local.instance_subnets

  tags        = merge(local.amway_common_tags, local.amway_instance_tags, local.amway_data_tags)
  volume_tags = merge(local.amway_common_tags, local.amway_data_tags)

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = 20
      delete_on_termination = true
    },
  ]
}

module "nexus_s3_cd_builds" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "amway-eu-aweu-eia"
  acl    = "private"

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}

module "nexus_s3_static_files" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "amway-eu-static-files"
  acl    = "private"

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}

module "nexus_s3_docker_files" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "amway-eu-docker-files"
  acl    = "private"

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}
