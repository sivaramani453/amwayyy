module "mdms_proxy_ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.17.0"

  name        = "mdms-proxy-${terraform.workspace}-sg"
  description = "Security group for MDMS Proxy instances"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
      description = "Allow web within private ip range (proxy traffic requests)"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
      description = "Allow web within private ip range (proxy traffic requests)"
    },
  ]

  egress_rules = ["all-all"]

  tags = "${local.amway_common_tags}"
}
