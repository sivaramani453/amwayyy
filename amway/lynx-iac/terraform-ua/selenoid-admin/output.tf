output "instances_sg_id" {
  description = "The ID of the security group created for Selenoid service intsances"
  value       = "${aws_security_group.EIA-selenoid.id}"
}
