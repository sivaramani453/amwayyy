data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "eks-v2/core.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "nlbs" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "eks-v2/nlbs.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_security_group" "kube-workers" {
  name   = "eks-v2-workers-custom-sg"
  vpc_id = "${data.terraform_remote_state.core.vpc_id}"

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]
    description = "Allow NodePorts"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "eks-v2-workers-custom-sg"
    Terraform = "true"
  }
}

module "eks" {
  source = "../modules/tf-module-aws-eks"

  project     = "amway"
  environment = "eks"

  cluster_version           = "1.14"
  cluster_enabled_log_types = ["api"]

  vpc_id                  = "${data.terraform_remote_state.core.vpc_id}"
  spot_subnets            = "${data.terraform_remote_state.core.spot_subnets}"
  additional_spot_subnets = "${data.terraform_remote_state.core.additional_spot_subnets}"
  public_subnets          = "${data.terraform_remote_state.core.public_subnets}"
  additional_sg_id        = "${aws_security_group.kube-workers.id}"
  target_group_arns       = "${data.terraform_remote_state.nlbs.target_group_arns}"

  spot_configuration = [
    {
      instance_type              = "t3.large"
      additional_instance_type_1 = "m4.large"
      additional_instance_type_2 = "m5.large"
      spot_price                 = "0.05"
      asg_max_size               = "6"
      asg_min_size               = "1"
      asg_desired_capacity       = "1"
      additional_kubelet_args    = ""
    },
    {
      instance_type              = "t3.xlarge"
      additional_instance_type_1 = "m4.xlarge"
      additional_instance_type_2 = "m5.xlarge"
      spot_price                 = "0.1"
      asg_max_size               = "8"
      asg_min_size               = "1"
      asg_desired_capacity       = "1"
      additional_kubelet_args    = ""
    },
  ]

  on_demand_configuration = [
    {
      instance_type           = "t3.xlarge"
      asg_max_size            = "8"
      asg_min_size            = "0"
      asg_desired_capacity    = "0"
      additional_kubelet_args = ""
    },
  ]

  service_on_demand_configuration = [
    {
      instance_type           = "t3.medium"
      asg_max_size            = "2"
      asg_min_size            = "1"
      asg_desired_capacity    = "1"
      additional_kubelet_args = ""
    },
  ]

  # epam-se
  worker_nodes_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYzrIi812f6c3kl1zT5Axsa64swP8oRE+nvOrUSrKtO1K304STyZRod58RCCoQYGDhKzzDpUDrE9d1NHVRh357N/+x7TAysHoAbKQ2t9t84CCJyXQj9F6w5eMPmYqzYTql0Oj1/wwht3lHbj3haywW24kjJESufL5PAZvuP/UBuhALdjmDXGhWeQlwDj4tkKSsJDEjwXAcJj+rhOXcAO/NVZq9lnKU9wEXGV0RsgjdDFUe5NY9sI5WPKpS60f33hsoRUuTpj9KgQIPUZnC9dQ0+APvMegecdywWB5GTxp/sltuKDq1sfmxx4M0lya8sU6t8c9StP/H9inB4MjPiq1N"

  deploy_external_dns = true
  external_dns_policy = "upsert-only"
  root_domain         = "hybris.eia.amway.net"
}
