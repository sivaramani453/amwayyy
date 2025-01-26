output "prerender_lb_endpoint" {
  value = "${aws_lb.prerender_ext_lb.dns_name}"
}

output "prerender_redis_cluster_endpoint" {
  value = "${aws_elasticache_replication_group.redis_cluster.configuration_endpoint_address}"
}
