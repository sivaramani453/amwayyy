data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "zabbix_server_ami" {
  owners      = ["self", "amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["zabbix-server*"]
  }
}

resource "aws_instance" "zabbix-server" {
  ami           = "${data.aws_ami.zabbix_server_ami.id}"
  instance_type = "t3.large"
  ebs_optimized = "true"

  key_name               = "EPAM-SE"
  vpc_security_group_ids = ["${aws_security_group.zabbix-server.id}"]
  subnet_id              = "${data.terraform_remote_state.core.subnet.core_a.id}"

  root_block_device = [{
    volume_type           = "gp2"
    volume_size           = "100"
    delete_on_termination = true
  }]

  tags = "${merge(local.amway_common_tags, local.instance_tags, local.data_tags, local.tags)}"
}

resource "aws_route53_record" "zabbix-server" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "zabbix.hybris.eia.amway.net"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.zabbix-server.private_ip}"]
}
