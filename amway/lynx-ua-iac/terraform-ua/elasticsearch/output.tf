output "elasticsearch" {
  value = "${aws_elasticsearch_domain.epam-elasticsearch.endpoint}"
}

output "kibana" {
  value = "${aws_elasticsearch_domain.epam-elasticsearch.kibana_endpoint}"
}
