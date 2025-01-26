output "sonarqube_id" {
  value = "${aws_instance.sonarqube.id}"
}

output "sonarqube_ip" {
  value = "${aws_instance.sonarqube.private_ip}"
}
