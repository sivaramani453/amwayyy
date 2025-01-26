output "instance_ip" {
  value = module.ec2_windows.private_ip
}

output "instance_id" {
  value = module.ec2_windows.id
}
