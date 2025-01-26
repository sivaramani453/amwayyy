output "elasticsearch_endpoint" {
  value = aws_elasticsearch_domain.elasticsearch_cluster.endpoint
}

output "kibana_endpoint" {
  value = aws_elasticsearch_domain.elasticsearch_cluster.kibana_endpoint
}

output "custom_endpoint" {
  value = aws_route53_record.custom_endpoint.name
}
