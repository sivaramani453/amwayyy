output "vpc.virginia_default.id" {
  value = "${aws_default_vpc.virginia_default.id}"
}

output "vpc.virginia_default.cidr_block" {
  value = "${aws_default_vpc.virginia_default.cidr_block}"
}

output "vpc.virginia_dev.id" {
  value = "${aws_vpc.virginia_dev.id}"
}

output "vpc.virginia_dev.cidr_block" {
  value = "${aws_vpc.virginia_dev.cidr_block}"
}

output "subnet.virginia_dev.virginia_dev_a.id" {
  value = "${aws_subnet.virginia_dev_a.id}"
}

output "subnet.virginia_dev.virginia_dev_b.id" {
  value = "${aws_subnet.virginia_dev_b.id}"
}

output "subnet.virginia_dev.virginia_dev_c.id" {
  value = "${aws_subnet.virginia_dev_c.id}"
}

output "subnet.virginia_dev.virginia_public_a.id" {
  value = "${aws_subnet.virginia_public_a.id}"
}

output "subnet.virginia_dev.virginia_public_b.id" {
  value = "${aws_subnet.virginia_public_b.id}"
}

output "subnet.virginia_dev.virginia_public_c.id" {
  value = "${aws_subnet.virginia_public_c.id}"
}

output "subnet.virginia_default.virginia_default_a.id" {
  value = "${aws_default_subnet.virginia_default_a.id}"
}

output "subnet.virginia_default.virginia_default_b.id" {
  value = "${aws_default_subnet.virginia_default_b.id}"
}

output "subnet.virginia_default.virginia_default_c.id" {
  value = "${aws_default_subnet.virginia_default_c.id}"
}

output "subnet.virginia_default.virginia_default_d.id" {
  value = "${aws_default_subnet.virginia_default_d.id}"
}

output "subnet.virginia_default.virginia_default_e.id" {
  value = "${aws_default_subnet.virginia_default_e.id}"
}

output "subnet.virginia_default.virginia_default_f.id" {
  value = "${aws_default_subnet.virginia_default_f.id}"
}
