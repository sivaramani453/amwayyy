module "pgsql_rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "pgsql-rds-${terraform.workspace}-sg"
  description = "Security group vip-reports RDS"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = ["192.168.0.0/22"]
  ingress_rules       = ["postgresql-tcp"]

  egress_rules = ["all-all"]

  tags = "${local.tags}"
}
