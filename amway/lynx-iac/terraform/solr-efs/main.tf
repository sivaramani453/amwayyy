data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "efs_solr_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "efs-solr-sg"
  description = "Security group for solr-efs"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = ["${data.terraform_remote_state.core.vpc.dev.cidr_block}"]
  ingress_rules       = ["nfs-tcp"]
  egress_rules        = ["all-all"]

  tags = "${merge(local.amway_common_tags, local.data_tags, local.tags)}"
}

locals {
  efs_subnet_ids = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]
}

resource "aws_efs_file_system" "efs_solr" {
  tags = "${merge(local.amway_common_tags, local.data_tags, local.tags)}"
}

resource "aws_efs_mount_target" "efs_solr" {
  count          = "${length(local.efs_subnet_ids)}"
  file_system_id = "${aws_efs_file_system.efs_solr.id}"
  subnet_id      = "${element(local.efs_subnet_ids, count.index)}"

  security_groups = [
    "${module.efs_solr_sg.this_security_group_id}",
  ]
}

resource "aws_route53_record" "efs_solr_urls" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${aws_efs_file_system.efs_solr.id}.efs.${data.terraform_remote_state.core.route53.zone.name}"
  ttl     = "300"
  type    = "A"

  records = ["${aws_efs_mount_target.efs_solr.*.ip_address}"]
}
