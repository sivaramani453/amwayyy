locals {
  consul_server_pub = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAy3BzE8zppG8xanNJWALWEPwgQzuMxyj8Bcc4xmihxwgtSUdHv5XFvAQt38qrfbx0FOszXnbJ414a+AoIveQAUNqw9wBiTFXbwYfi3piMeoCeKLwGRlqo+6Yj8vemCMBhDvjI7HQblkkxTFJM2KcnBKomRLORbUfgSD/lsIr9kpTZQ8xO80ezTE4K4+qV+AzwPApgwkpnTO3gYCwc/VFLurCfpI3EKpzrvddRq6T2ZQtsYxuJVtf0KybzuXRgoFvzOPvlOehCmak+tIK4dMQzxABWfWg7KjpUpgSxjUvh3IXYxDBwQsKc2v4HU0ij5b2MV9PT7ACdu7qRszxxGd6P"
}

resource "aws_route53_record" "consul-nodes" {
  count = "${var.consul_cluster_size}"

  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "node${count.index}.consul.hybris.eia.amway.net"
  type    = "A"
  ttl     = "300"
  records = ["${element(module.consul-nodes.private_ip, count.index)}"]
}

resource "null_resource" "setup-consul-cluster" {
  count = "${var.consul_cluster_size}"

  connection {
    user        = "ec2-user"
    host        = "${module.consul-nodes.private_ip[count.index]}"
    type        = "ssh"
    private_key = "${file("~/aws/EPAM-SE.pem")}"
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "${path.module}/ssh_key/consul-server"
    destination = "/home/ec2-user/.ssh/consul-server"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/ec2-user/.ssh/consul-server",
      "echo ${local.consul_server_pub} >> /home/ec2-user/.ssh/authorized_keys",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/ansible/consul-cluster-playbook.yml"
    destination = "/home/ec2-user/consul-cluster-playbook.yml"
  }

  provisioner "file" {
    source      = "${path.module}/ansible/inventory"
    destination = "/home/ec2-user/inventory"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo pip install ansible",
      "ansible-galaxy install brianshumate.consul",
      "sudo yum install -y git unzip",
      "sudo pip install netaddr",

      # Here lies temporary fix for https://github.com/brianshumate/ansible-consul/pull/262 #
      "cat > ~/.ansible/roles/brianshumate.consul/vars/Amazon.yml <<EOF",

      "consul_os_packages: []",

      #      "  - git",
      #      "  - unzip",
      "consul_syslog_enable: true",

      "EOF",

      #######################################################################################
      "export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i inventory consul-cluster-playbook.yml",

      "ssh -i .ssh/consul-server node0.consul.hybris.eia.amway.net consul kv put packer/vpc_id ${data.terraform_remote_state.core.vpc.dev.id}",
      "ssh -i .ssh/consul-server node0.consul.hybris.eia.amway.net consul kv put packer/subnet_id ${data.terraform_remote_state.core.subnet.core_a.id}",
      "ssh -i .ssh/consul-server node0.consul.hybris.eia.amway.net consul kv put packer/encryption_key $(ssh -i .ssh/consul-server node0.consul.hybris.eia.amway.net consul keyring -list | grep '[*/*]' | head -1 | awk '{print $1}')",
    ]
  }

  triggers {
    cluster_instance_ids = "${join(",", aws_route53_record.consul-nodes.*.name)}"
  }
}
