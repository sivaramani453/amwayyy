data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "core-eks" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "eks-v2/core.tfstate"
    region = "eu-central-1"
  }
}

module "eks_efs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "eks-efs-sg"
  description = "Security group for EKS EFS"
  vpc_id      = "${data.terraform_remote_state.core-eks.vpc_id}"

  ingress_cidr_blocks = ["${data.terraform_remote_state.core-eks.vpc_cidr_block}"]
  ingress_rules       = ["nfs-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_efs_file_system" "eks_efs" {
  tags {
    Terraform = "True"
    Name      = "${terraform.workspace}-efs"
  }
}

resource "aws_efs_mount_target" "eks_efs" {
  count          = "${length(data.terraform_remote_state.core-eks.infra_subnets)}"
  file_system_id = "${aws_efs_file_system.eks_efs.id}"
  subnet_id      = "${element(data.terraform_remote_state.core-eks.infra_subnets, count.index)}"

  security_groups = [
    "${module.eks_efs_sg.this_security_group_id}",
  ]
}

resource "aws_route53_record" "efs_urls" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${aws_efs_file_system.eks_efs.id}.efs.${data.terraform_remote_state.core.route53.zone.name}"
  ttl     = "300"
  type    = "A"

  records = ["${aws_efs_mount_target.eks_efs.*.ip_address}"]
}
