module "vault_cluster_sg_lb" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${terraform.workspace}-lb-sg"
  description = "Allow traffic into the vault cluster lb"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]

  computed_egress_with_source_security_group_id = [
    {
      from_port                = 8200
      to_port                  = 8200
      protocol                 = "tcp"
      source_security_group_id = module.vault_cluster_sg_ec2.this_security_group_id
    },
  ]

  number_of_computed_egress_with_source_security_group_id = 1

  tags = local.amway_common_tags
}

module "vault_cluster_sg_ec2" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${terraform.workspace}-ec2-sg"
  description = "Allow traffic from lb to ec2 and ec2 to ec2"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 8200
      to_port                  = 8200
      protocol                 = "tcp"
      source_security_group_id = module.vault_cluster_sg_lb.this_security_group_id
    },
  ]

  ingress_with_self = [
    {
      from_port = 8201
      to_port   = 8201
      protocol  = "tcp"
      self      = true
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = local.amway_common_tags

}
