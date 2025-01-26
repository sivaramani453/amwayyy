provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "nexus_ec2_instance" {
  ami                    = "${data.aws_ami.latest_nexus_ami.id}"
  instance_type          = "t3.large"
  availability_zone      = "eu-central-1a"
  subnet_id              = "${data.terraform_remote_state.core.subnet.core_a.id}"
  vpc_security_group_ids = ["${data.aws_security_group.main.id}"]

  tags = "${local.tags}"

  root_block_device {
    volume_type           = "gp3"
    volume_size           = "20"
    delete_on_termination = "true"
  }
}
