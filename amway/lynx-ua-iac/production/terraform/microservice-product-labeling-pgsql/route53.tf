resource "aws_route53_record" "product_labeling_postgresql_url" {
  zone_id = "${data.terraform_remote_state.core.route53_zone_id}"
  name    = "${terraform.workspace}-postgresql.ms.eia.amway.net"
  ttl     = "300"
  type    = "A"

  records = ["${module.ec2_product_labeling_postgresql_instance.private_ip}"]
}

resource "aws_route53_record" "efs_urls" {
  zone_id = "${data.terraform_remote_state.core.route53_zone_id}"
  name    = "${aws_efs_file_system.efs_product_labeling_fs.id}.efs.ms.eia.amway.net"
  ttl     = "300"
  type    = "A"

  records = ["${aws_efs_mount_target.efs_product_labeling_mt.*.ip_address}"]
}
