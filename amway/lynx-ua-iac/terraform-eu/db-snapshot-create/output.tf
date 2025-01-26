output "instance_ip" {
  value = module.ec2_instance.private_ip
}

output "instance_id" {
  value = module.ec2_instance.id
}
