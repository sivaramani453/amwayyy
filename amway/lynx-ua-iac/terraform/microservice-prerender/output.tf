output "prerender_redis_cluster_endpoint" {
  value = "${aws_elasticache_replication_group.redis_cluster.configuration_endpoint_address}"
}
