output "masters_instance_ids" {
  value = "${aws_instance.kube-masters.*.id}"
}

output "workers_instance_ids" {
  value = "${aws_instance.kube-workers.*.id}"
}

output "masters_private_ips" {
  value = "${aws_instance.kube-masters.*.private_ip}"
}

output "workers_sg" {
  value = "${aws_security_group.kube-workers.id}"
}

output "masters_private_ips_formatted" {
  value = "${join(" ", aws_instance.kube-masters.*.private_ip)}"
}

output "workers_private_ips" {
  value = "${aws_instance.kube-workers.*.private_ip}"
}

output "workers_private_ips_formatted" {
  value = "${join(" ", aws_instance.kube-workers.*.private_ip)}"
}

output "dns_name" {
  value = "${var.cluster_name}.${var.route53_zone_name}"
}

output "s3_bucket_name" {
  value = "${module.s3_bucket.bucket_id}"
}

output "s3_bucket_arn" {
  value = "${module.s3_bucket.bucket_arn}"
}

output "nlb_dns_name" {
  value = "${module.load_balancer.dns_name}"
}
