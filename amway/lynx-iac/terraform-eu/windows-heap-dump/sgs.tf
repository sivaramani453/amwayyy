module "windows_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.17.0"

  name        = "windows-heap-dump-sg"
  description = "Security group for Windows machine"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  

  ingress_with_cidr_blocks = [
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
    #  rule        = "rdp"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
    
  ]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}
