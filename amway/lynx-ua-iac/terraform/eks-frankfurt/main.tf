data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.67.0"

  name = "amway-frankfurt-eks"

  cidr = "192.168.0.0/22"

  # Subnets
  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["192.168.0.0/25", "192.168.0.128/25", "192.168.1.0/25"]
  public_subnets  = ["192.168.1.128/25", "192.168.2.0/25", "192.168.2.128/25"]

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_dhcp_options  = true

  # NAT
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/amway-frankfurt-dev" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/amway-frankfurt-dev" = "shared"
  }

  vpc_tags = {
    "kubernetes.io/cluster/amway-frankfurt-dev" = "shared"
  }

  tags = {
    Terraform   = "true"
    Service     = "amway-frankfurt-eks"
    Environment = "dev"
  }
}

module "eks" {
  source = "../modules/tf-module-aws-eks"

  project     = "amway"
  environment = "frankfurt-dev"

  cluster_version           = "1.14"
  cluster_enabled_log_types = ["api"]

  vpc_id          = "${module.vpc.vpc_id}"
  private_subnets = "${module.vpc.private_subnets}"
  public_subnets  = "${module.vpc.public_subnets}"

  spot_configuration = [
    {
      instance_type              = "t3.large"
      additional_instance_type_1 = "m4.large"
      additional_instance_type_2 = "m5.large"
      spot_price                 = "0.05"
      asg_max_size               = "4"
      asg_min_size               = "1"
      asg_desired_capacity       = "1"
      additional_kubelet_args    = ""
    },
    {
      instance_type              = "t3.xlarge"
      additional_instance_type_1 = "m4.xlarge"
      additional_instance_type_2 = "m5.xlarge"
      spot_price                 = "0.1"
      asg_max_size               = "4"
      asg_min_size               = "0"
      asg_desired_capacity       = "0"
      additional_kubelet_args    = ""
    },
  ]

  on_demand_configuration = [
    {
      instance_type           = "t3.xlarge"
      asg_max_size            = "6"
      asg_min_size            = "0"
      asg_desired_capacity    = "0"
      additional_kubelet_args = ""
    },
  ]

  service_on_demand_configuration = [
    {
      instance_type           = "t3.small"
      asg_max_size            = "1"
      asg_min_size            = "1"
      asg_desired_capacity    = "1"
      additional_kubelet_args = ""
    },
  ]

  worker_nodes_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzX3UBP+PcRwT+KtM3jxlAPrsihEaFaKN74SafmeL0WwCCIk0doHihXc4/bW3Np1VgV8b9Jlr63g7eIFlzdlG3KxqFXFbG+TF/oNjmdmConzQ0uj7l75+xBEBYfN//ZEx5H9V5Am1G/gd/dCGUVV7lyae2CqipNwHsPcfweQixg5huh1cn8511fpYDKSRdVI+qF3flBo6lwNALQI23+TJ8mGHW/Hj3iw1FWD3JqK/gKr1Wvrit1v7gCDQ8wNDVRp/3FElCrH+DQlXgs74x7z6NeZbGUvCfLwOuDFVWOFQr2mvBDpNuCVEB188bHWW2dj9dzv3YCFIGxoPP2dUUIFur"

  deploy_external_dns = true
  external_dns_policy = "upsert-only"
  root_domain         = "hybris.eia.amway.net"
}

resource "aws_vpc_peering_connection" "eks-with-main" {
  peer_vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"
  vpc_id      = "${module.vpc.vpc_id}"
  auto_accept = true

  tags = {
    Name      = "VPC Peering between eks-frankfurt and eia-hybris"
    Terraform = "true"
  }
}

resource "aws_route" "eks" {
  count                     = "${length(module.vpc.private_subnets)}"
  route_table_id            = "${module.vpc.private_route_table_ids[count.index]}"
  destination_cidr_block    = "${data.terraform_remote_state.core.vpc.dev.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.eks-with-main.id}"
  depends_on                = ["module.vpc", "aws_vpc_peering_connection.eks-with-main"]
}
