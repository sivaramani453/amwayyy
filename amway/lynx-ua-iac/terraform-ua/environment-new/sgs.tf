module "be_nodes_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "be-${terraform.workspace}-sg"
  description = "Security group for Backend Nodes"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = ["${data.terraform_remote_state.core.vpc.dev.cidr_block}"]
  ingress_rules       = ["zookeeper-2181-tcp", "zookeeper-2888-tcp", "zookeeper-3888-tcp", "nfs-tcp"]

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
    {
      rule        = "mysql-tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
    {
      from_port   = 8983
      to_port     = 8983
      protocol    = "tcp"
      description = "Solr port"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
    {
      from_port   = 9001
      to_port     = 9005
      protocol    = "tcp"
      description = "Hybris ports"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
    {
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      description = "Zabbix agent port"
      cidr_blocks = "${data.terraform_remote_state.core.vpc.dev.cidr_block}"
    },
    {
      from_port   = 7800
      to_port     = 7800
      protocol    = "tcp"
      description = "Hybris cluster port"
      cidr_blocks = "${data.terraform_remote_state.core.vpc.dev.cidr_block}"
    },
  ]

  egress_rules = ["all-all"]
}

module "fe_nodes_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "fe-${terraform.workspace}-sg"
  description = "Security group for Frontend Nodes"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = ["${data.terraform_remote_state.core.vpc.dev.cidr_block}"]
  ingress_rules       = ["zookeeper-2181-tcp", "zookeeper-2888-tcp", "zookeeper-3888-tcp"]

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
    {
      rule        = "mysql-tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
    {
      from_port   = 8983
      to_port     = 8983
      protocol    = "tcp"
      description = "Solr port"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
    {
      from_port   = 9001
      to_port     = 9005
      protocol    = "tcp"
      description = "Hybris ports"
      cidr_blocks = "${data.terraform_remote_state.core.vpc.dev.cidr_block}"
    },
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      description = "Hybris Storybook access port"
      cidr_blocks = "${data.terraform_remote_state.core.vpc.dev.cidr_block}"
    },
    {
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      description = "Zabbix agent port"
      cidr_blocks = "${data.terraform_remote_state.core.vpc.dev.cidr_block}"
    },
    {
      from_port   = 7800
      to_port     = 7800
      protocol    = "tcp"
      description = "Hybris cluster port"
      cidr_blocks = "${data.terraform_remote_state.core.vpc.dev.cidr_block}"
    },
  ]

  egress_rules = ["all-all"]
}

module "alb_nodes_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "alb-${terraform.workspace}-sg"
  description = "Security group for the ALB of the FE and BE nodes"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["https-443-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      description = "Hybris Storybook access port"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
  ]

  egress_rules = ["all-all"]
}
