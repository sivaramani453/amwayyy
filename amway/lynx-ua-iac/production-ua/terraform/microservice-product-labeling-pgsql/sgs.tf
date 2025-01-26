module "product_labeling_postgresql_instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "pgsql-instance-${terraform.workspace}-sg"
  description = "Security group for PgSQL instance"
  vpc_id      = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["postgresql-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]

  tags = "${merge(map("Name", "pl-pgsql-${terraform.workspace}-sg"), local.amway_common_tags)}"
}

module "efs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "efs-${terraform.workspace}-sg"
  description = "Security group for EFS"
  vpc_id      = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"

  ingress_cidr_blocks = "${local.kube_subnet_cidrs}"
  ingress_rules       = ["nfs-tcp"]
  egress_rules        = ["all-all"]

  tags = "${merge(map("Name", "pl-efs-${terraform.workspace}-sg"), local.amway_common_tags)}"
}
