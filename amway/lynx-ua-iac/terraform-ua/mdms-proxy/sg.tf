module "mdms_proxy_ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "mdms-proxy-${terraform.workspace}-sg"
  description = "Security group for MDMS Proxy instances"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
    {
      from_port   = 1235
      to_port     = 1235
      protocol    = "tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
      description = "Allow web within private ip range (proxy traffic requests)"
    },
  ]

  egress_rules = ["all-all"]

  tags = "${local.amway_common_tags}"
}
