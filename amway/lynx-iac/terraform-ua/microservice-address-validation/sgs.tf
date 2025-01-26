module "zookeeper_ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "zookeeper-cluster-${terraform.workspace}-sg"
  description = "Security group for Zookeeper EC2 instances"
  vpc_id      = "${data.terraform_remote_state.core-eks.vpc_id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["zookeeper-2181-tcp", "zookeeper-2888-tcp", "zookeeper-3888-tcp"]

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
  ]

  egress_rules = ["all-all"]

  tags = "${local.amway_common_tags}"
}

module "solr_ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "solr-cluster-${terraform.workspace}-sg"
  description = "Security group for Solr EC2 instances"
  vpc_id      = "${data.terraform_remote_state.core-eks.vpc_id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 8983
      to_port     = 8983
      protocol    = "tcp"
      description = "Solr port"
      cidr_blocks = "${join(",", local.vpn_subnet_cidrs)}"
    },
  ]

  egress_rules = ["all-all"]

  tags = "${local.amway_common_tags}"
}

module "pgsql_rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "pgsql-rds-${terraform.workspace}-sg"
  description = "Security group for PgSQL RDS instance"
  vpc_id      = "${data.terraform_remote_state.core-eks.vpc_id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]

  tags = "${local.amway_common_tags}"
}

#module "efs_sg" {
#  source  = "terraform-aws-modules/security-group/aws"
#  version = "~> 2.0"

#  name        = "efs-${terraform.workspace}-sg"
#  description = "Security group for EFS"
#  vpc_id      = "${data.terraform_remote_state.core-eks.vpc_id}"

#  ingress_cidr_blocks = ["${data.terraform_remote_state.core-eks.vpc_cidr_block}"]
#  ingress_rules       = ["nfs-tcp"]
#  egress_rules        = ["all-all"]

#  tags = "${local.amway_common_tags}"
#}
