output "solr_ec2_cluster_route53_urls" {
  value = "${aws_route53_record.efs_solr_urls.name}"
}
