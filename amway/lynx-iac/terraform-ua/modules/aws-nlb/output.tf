output "aws_lb_target_group_arn" {
  description = "List of IDs of instances"
  value       = ["${aws_lb_target_group.target_group.*.id}"]
}

output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = "${aws_lb.network_loadbalancer.dns_name}"
}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = "${aws_lb.network_loadbalancer.zone_id}"
}
