output "instance_ip" {
  value = module.ec2_dev_debug.private_ip
}

output "instance_id" {
  value = module.ec2_dev_debug.id
}
