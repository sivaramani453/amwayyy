module "nexus_ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.17.0"

  name        = "EPAM-nexus-ec2-sg"
  description = "Security group for Nexus instance"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  number_of_computed_ingress_with_source_security_group_id = 2
  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 8081
      to_port                  = 8081
      protocol                 = "tcp"
      source_security_group_id = module.nexus_alb_sg.this_security_group_id
      description              = "Allow traffic for Nexus web UI"
    },
    {
      from_port                = 8083
      to_port                  = 8083
      protocol                 = "tcp"
      source_security_group_id = module.nexus_alb_sg.this_security_group_id
      description              = "Allow traffic for Nexus Docker API"
    },
  ]


  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    }
  ]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

module "nexus_alb_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 3.17.0"
  name        = "EPAM-nexus-alb-sg"
  description = "Security group for nexus alb with HTTP and HTTPS ports open"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id
  tags        = local.amway_common_tags

  egress_rules        = ["all-all"]
  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8083
      to_port     = 8083
      protocol    = "tcp"
      description = "Docker Hub API"
      cidr_blocks = "10.0.0.0/8"
    }
  ]
}