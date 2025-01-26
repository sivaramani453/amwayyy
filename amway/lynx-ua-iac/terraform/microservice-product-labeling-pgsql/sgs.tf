module "product_labeling_postgresql_instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "pgsql-instance-${terraform.workspace}-sg"
  description = "Security group for PgSQL instance"
  vpc_id      = "${data.terraform_remote_state.core-eks.vpc_id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["postgresql-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]

  tags = "${local.custom_tags_common}"
}

module "efs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "efs-${terraform.workspace}-sg"
  description = "Security group for EFS"
  vpc_id      = "${data.terraform_remote_state.core-eks.vpc_id}"

  ingress_cidr_blocks = ["${data.terraform_remote_state.core-eks.vpc_cidr_block}"]
  ingress_rules       = ["nfs-tcp"]
  egress_rules        = ["all-all"]

  tags = "${local.custom_tags_common}"
}
