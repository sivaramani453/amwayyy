output "instance_ip" {
  value = "${module.ec2-instance.private_ip}"
}

output "instance_id" {
  value = "${module.ec2-instance.id}"
}

output "db_volume_id" {
  value = "${aws_ebs_volume.db.id}"
}

output "media_volume_id" {
  value = "${aws_ebs_volume.media.id}"
}
