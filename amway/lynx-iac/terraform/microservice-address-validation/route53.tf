resource "aws_route53_record" "zookeeper_node_urls" {
  count   = "${var.zookeeper_instance_count}"
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${terraform.workspace}-zookeeper-node-${count.index}.${data.terraform_remote_state.core.route53.zone.name}"
  ttl     = "300"
  type    = "A"

  records = ["${element(module.ec2_zookeeper_instance.private_ip, count.index)}"]
}

resource "aws_route53_record" "solr_node_urls" {
  count   = "${var.solr_instance_count}"
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${terraform.workspace}-solr-node-${count.index}.${data.terraform_remote_state.core.route53.zone.name}"
  ttl     = "300"
  type    = "A"

  records = ["${element(module.ec2_solr_instance.private_ip, count.index)}"]
}

resource "aws_route53_record" "efs_urls" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${aws_efs_file_system.efs_address_validation_fs.id}.efs.${data.terraform_remote_state.core.route53.zone.name}"
  ttl     = "300"
  type    = "A"

  records = ["${aws_efs_mount_target.efs_address_validation_mt.*.ip_address}"]
}
