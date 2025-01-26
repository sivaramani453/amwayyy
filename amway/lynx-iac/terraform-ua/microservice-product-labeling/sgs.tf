module "pl_nodes_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "${terraform.workspace}-sg"
  description = "Security group for Product Labeling Nodes"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Product Labeling access port"
      source_security_group_id = "${module.alb_nodes_sg.this_security_group_id}"
    },
    {
      from_port                = 9001
      to_port                  = 9001
      protocol                 = "tcp"
      description              = "Product Labeling health check port"
      source_security_group_id = "${module.alb_nodes_sg.this_security_group_id}"
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 2

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
  ]

  egress_rules = ["all-all"]

  tags = "${local.custom_tags_common}"
}

module "alb_nodes_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "alb-${terraform.workspace}-sg"
  description = "Security group for the ALB of the Product Labeling Nodes"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = "${local.custom_tags_common}"
}
