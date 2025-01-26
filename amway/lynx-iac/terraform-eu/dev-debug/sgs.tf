module "es2_dev_debug_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "dev-${var.instance_name}-sg"
  description = "Security group for Dev Debug machine"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["ssh-tcp", "mysql-tcp", "https-443-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = "IntelliJ IDEA Java remote debug"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
    {
      from_port   = 8983
      to_port     = 8983
      protocol    = "tcp"
      description = "Solr port"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
    {
      from_port   = 9001
      to_port     = 9005
      protocol    = "tcp"
      description = "Hybris ports"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
    {
      from_port   = 5901
      to_port     = 5901
      protocol    = "tcp"
      description = "Tiger VNC port"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
    {
      from_port   = 5902
      to_port     = 5902
      protocol    = "tcp"
      description = "Projector port"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
    {
      from_port   = 9999
      to_port     = 9999
      protocol    = "tcp"
      description = "default Projector port"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "Samba - Microsoft Directory Service"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
    {
      from_port   = 139
      to_port     = 139
      protocol    = "tcp"
      description = "Samba - NetBIOS Session Service"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
  ]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}
