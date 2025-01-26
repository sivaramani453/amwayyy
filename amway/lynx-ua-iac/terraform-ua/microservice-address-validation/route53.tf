# resource "aws_route53_record" "zookeeper_node_urls" {
#   count   = var.zookeeper_instance_count
#   zone_id = var.zone_id
#   name    = "${terraform.workspace}-zookeeper-node-${count.index}.${var.zone_name}"
#   ttl     = "300"
#   type    = "A"

#   # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
#   # force an interpolation expression to be interpreted as a list by wrapping it
#   # in an extra set of list brackets. That form was supported for compatibility in
#   # v0.11, but is no longer supported in Terraform v0.12.
#   #
#   # If the expression in the following list itself returns a list, remove the
#   # brackets to avoid interpretation as a list of lists. If the expression
#   # returns a single list item then leave it as-is and remove this TODO comment.
#   records = [element(module.ec2_zookeeper_instance.private_ip, count.index)]
# }

# resource "aws_route53_record" "solr_node_urls" {
#   count   = var.solr_instance_count
#   zone_id = var.zone_id
#   name    = "${terraform.workspace}-solr-node-${count.index}.${var.zone_name}"
#   ttl     = "300"
#   type    = "A"

#   # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
#   # force an interpolation expression to be interpreted as a list by wrapping it
#   # in an extra set of list brackets. That form was supported for compatibility in
#   # v0.11, but is no longer supported in Terraform v0.12.
#   #
#   # If the expression in the following list itself returns a list, remove the
#   # brackets to avoid interpretation as a list of lists. If the expression
#   # returns a single list item then leave it as-is and remove this TODO comment.
#   records = [element(module.ec2_solr_instance.private_ip, count.index)]
# }

# resource "aws_route53_record" "efs_urls" {
#  zone_id = "${var.zone_id}"
#  name    = "${aws_efs_file_system.efs_address_validation_fs.id}.efs.${var.zone_id}"
#  ttl     = "300"
#  type    = "A"
#  records = aws_efs_mount_target.efs_address_validation_mt.*.ip_address
# }
