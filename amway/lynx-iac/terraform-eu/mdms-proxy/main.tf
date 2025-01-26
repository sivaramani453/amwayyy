module "mdms_proxy_server_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.16.0"

  name           = "mdms-proxy-server-${terraform.workspace}"
  instance_count = "1"

  ami                    = "${data.aws_ami.latest_mdms_proxy_ami.id}"
  ebs_optimized          = true
  instance_type          = "t3.medium"
  key_name               = data.terraform_remote_state.core.outputs.frankfurt_ssh_key
  monitoring             = true
  vpc_security_group_ids = ["${module.mdms_proxy_ec2_sg.this_security_group_id}"]
  subnet_ids             = local.instance_subnets

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = 20
      delete_on_termination = true
    },
  ]

  tags        = "${merge(local.amway_common_tags, local.amway_ec2_specific_tags)}"
  volume_tags = "${merge(map("ServiceType", "mdms-api-proxy"), local.amway_common_tags, local.amway_ebs_specific_tags)}"
}
