module "pgsql_rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "pgsql-rds-${terraform.workspace}-sg"
  description = "Security group for PgSQL RDS instance"
  vpc_id      = data.terraform_remote_state.core.outputs.vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]

  tags = local.amway_common_tags
}
