output "instance_ip" {
  value = "${module.ec2-instance.private_ip}"
}

output "instance_id" {
  value = "${module.ec2-instance.id}"
}
