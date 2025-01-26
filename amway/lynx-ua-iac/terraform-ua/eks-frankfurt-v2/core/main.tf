locals {
  azs                             = ["eu-central-1a", "eu-central-1b"]
  spot_workers_subnets            = ["10.130.8.0/23", "10.130.10.0/23"]
  additional_spot_workers_subnets = ["10.130.12.0/25", "10.130.12.128/25"]
  private_elb_subnets             = ["10.130.13.0/25", "10.130.13.128/25"]
  public_elb_subnets              = ["10.130.14.0/25", "10.130.14.128/25"]
  database_subnets                = ["10.130.15.0/27", "10.130.15.32/27"]
  infra_subnets                   = ["10.130.15.64/27", "10.130.15.96/27"]
  infra_64_subnets                = ["10.130.15.128/26", "10.130.15.192/26"]
  subnet_postfixes                = ["a", "b"]
}

module "frankfurt_eks_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #version = "1.73.0"
  version = "v2.0"

  name = "amway-eks-v2-dev"

  cidr = "10.130.8.0/21"

  # Subnets
  azs                                = local.azs
  database_subnets                   = local.database_subnets
  private_subnets                    = local.private_elb_subnets
  public_subnets                     = local.public_elb_subnets
  propagate_private_route_tables_vgw = true

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_dhcp_options  = true

  # NAT
  enable_nat_gateway     = true
  one_nat_gateway_per_az = false

  # TAGS
  database_subnet_tags = {
    Purpose = "eks-rds-subnet"
  }

  nat_gateway_tags = {
    Name = "frankfurt-eks-nat-gw"
  }

  nat_eip_tags = {
    Name = "frankfurt-eks-nat-eip"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"          = "1"
    "kubernetes.io/cluster/amway-eks" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/amway-eks" = "shared"
  }

  vpc_tags = {
    "kubernetes.io/cluster/amway-eks" = "shared"
  }

  tags = {
    Terraform     = "true"
    Service       = "amway-frankfurt-eks-v2"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }
}

resource "aws_subnet" "spot_workers" {
  count             = length(local.azs)
  vpc_id            = module.frankfurt_eks_vpc.vpc_id
  cidr_block        = element(local.spot_workers_subnets, count.index)
  availability_zone = element(local.azs, count.index)

  tags = {
    Name                                  = "eks-spot-0-${element(local.subnet_postfixes, count.index)}"
    "kubernetes.io/cluster/amway-eks"     = "shared"
    Terraform                             = "true"
    ApplicationID                         = "APP1433689"
    Environment                           = "DEV"
    "kubernetes.io/role/internal-elb"     = "1"
  }
}

resource "aws_subnet" "ondemand_workers" {
  count             = length(local.azs)
  vpc_id            = module.frankfurt_eks_vpc.vpc_id
  cidr_block        = element(local.additional_spot_workers_subnets, count.index)
  availability_zone = element(local.azs, count.index)

  tags = {
    Name                                  = "eks-spot-1-${element(local.subnet_postfixes, count.index)}"
    "kubernetes.io/cluster/frankfurt-dev" = "shared"
    Terraform                             = "true"
    ApplicationID                         = "APP1433689"
    Environment                           = "DEV"
  }
}

resource "aws_subnet" "infra_subnets" {
  count             = length(local.azs)
  vpc_id            = module.frankfurt_eks_vpc.vpc_id
  cidr_block        = element(local.infra_subnets, count.index)
  availability_zone = element(local.azs, count.index)

  tags = {
    Name          = "infra-subnet-${element(local.subnet_postfixes, count.index)}"
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }
}

resource "aws_subnet" "infra_64_subnets" {
  count             = length(local.azs)
  vpc_id            = module.frankfurt_eks_vpc.vpc_id
  cidr_block        = element(local.infra_64_subnets, count.index)
  availability_zone = element(local.azs, count.index)

  tags = {
    Name          = "infra-64-subnet-${element(local.subnet_postfixes, count.index)}"
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }
}

resource "aws_route_table_association" "frankfurt_private" {
  count = length(
    concat(
      local.additional_spot_workers_subnets,
      local.spot_workers_subnets,
      local.infra_subnets,
      local.infra_64_subnets,
    ),
  )

  subnet_id = element(
    concat(
      aws_subnet.ondemand_workers.*.id,
      aws_subnet.spot_workers.*.id,
      aws_subnet.infra_subnets.*.id,
      aws_subnet.infra_64_subnets.*.id,
    ),
    count.index,
  )
  route_table_id = element(
    module.frankfurt_eks_vpc.private_route_table_ids,
    count.index,
  )
}

