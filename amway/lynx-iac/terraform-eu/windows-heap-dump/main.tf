data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "ec2_windows" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.16.0"

  name = "local.amway_ec2_tags"

  ami                         = var.ami
  instance_type               = "r5a.xlarge"
  key_name                    = "windows-heap-dumb-key"
  vpc_security_group_ids      = [module.windows_sg.this_security_group_id]
  subnet_id                   = "subnet-0a0f2b454712d3756"
  associate_public_ip_address = false
  source_dest_check           = true
  ebs_optimized               = true
  disable_api_termination     = true
  monitoring                  = false
  iam_instance_profile        = "allure_profile"

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "150"
      delete_on_termination = true
    },
  ]

  tags        = merge(local.amway_common_tags, local.amway_ec2_tags)
  volume_tags = local.amway_common_tags
}