output "aws-mount-target-dns" {
  description = "Address of the mount target provisioned."
  value       = "${aws_efs_mount_target.main.*.dns_name}"
}

output "custom-mount-target-dns" {
  description = "Custom dns name of mount target"
  value       = "${aws_route53_record.efs_mount_target.name}"
}
