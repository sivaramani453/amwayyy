data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  tags = "${map(
    "Environment", "${terraform.workspace}",
    "Schedule", "running",
    "Terraform", "True"
  )}"

  volume_tags = "${map(
    "Environment", "${terraform.workspace}",
    "ServiceType", "mdms-postgresql-instance",
    "Terraform", "True"
  )}"

  amway_tags = "${map(
    "SEC-INFRA-13", "Appliance",
    "SEC-INFRA-14", "Null",
  )}"

  amway_spec_tags = "${map(
    "DataClassification", "Internal",
    "ApplicationID", "APP3150571"
  )}"
}

module "ec2_mdms_postgresql_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 1.0"

  name           = "${terraform.workspace}-postgresql-instance"
  instance_count = "1"

  ami                    = "ami-0cf077499a07fcca4"
  ebs_optimized          = true
  instance_type          = "t3.large"
  key_name               = "EPAM-SE"
  monitoring             = true
  vpc_security_group_ids = ["${module.mdms_postgresql_instance_sg.this_security_group_id}"]
  subnet_ids             = ["${data.terraform_remote_state.core.subnet.core_a.id}"]

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = 20
      delete_on_termination = true
    },
  ]

  volume_tags = "${merge(local.volume_tags, local.amway_spec_tags)}"
  tags        = "${merge(local.tags, local.amway_spec_tags, local.amway_tags)}"
}

resource "aws_ebs_volume" "db" {
  availability_zone = "${module.ec2_mdms_postgresql_instance.availability_zone[0]}"
  type              = "gp3"
  size              = 100
  tags              = "${local.volume_tags}"
}

resource "aws_volume_attachment" "this_ec2_db" {
  device_name = "/dev/sdg"
  volume_id   = "${aws_ebs_volume.db.id}"
  instance_id = "${module.ec2_mdms_postgresql_instance.id[0]}"
}

module "mdms_postgresql_instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  name        = "pgsql-instance-${terraform.workspace}-sg"
  description = "Security group for PgSQL RDS instance"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/22"]
  ingress_rules       = ["postgresql-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_route53_record" "mdms_postgresql_url" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${terraform.workspace}-postgresql.${data.terraform_remote_state.core.route53.zone.name}"
  ttl     = "300"
  type    = "A"

  records = ["${module.ec2_mdms_postgresql_instance.private_ip}"]
}

resource "null_resource" "provisioning_the_postgresql_instance" {
  depends_on = ["aws_route53_record.mdms_postgresql_url", "aws_volume_attachment.this_ec2_db"]

  provisioner "local-exec" {
    on_failure = "fail"

    command = <<EOT
    echo "[postgresql]\n${aws_route53_record.mdms_postgresql_url.name}\n" > ./ansible/hosts;
    ansible-galaxy install -r ./ansible/requirements.yml -p ./ansible/roles/ -f;
    ansible-playbook ./ansible/bootstrap.yml -u centos -i ./ansible/hosts --extra-vars "docker_registry_username='${var.docker_registry_user}' docker_registry_password='${var.docker_registry_password}' "  --private-key="$PATH_TO_SSH_KEY";
    EOT

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      PATH_TO_SSH_KEY           = "${var.path_to_ssh_key}"
    }
  }
}
