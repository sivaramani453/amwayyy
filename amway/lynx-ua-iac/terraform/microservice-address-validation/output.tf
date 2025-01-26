output "zookeeper_ec2_cluster_private_ips" {
  value = "${module.ec2_zookeeper_instance.private_ip}"
}

output "solr_ec2_cluster_private_ips" {
  value = "${module.ec2_solr_instance.private_ip}"
}

output "zookeeper_ec2_cluster_route53_urls" {
  value = "${aws_route53_record.zookeeper_node_urls.*.name}"
}

output "solr_ec2_cluster_route53_urls" {
  value = "${aws_route53_record.solr_node_urls.*.name}"
}

output "pgsql_rds_endpoint_url" {
  value = "${module.rds_pgsql.this_db_instance_endpoint}"
}

output "efs_access_point_arn" {
  value = "${aws_efs_access_point.efs_address_validation_ap.arn}"
}
