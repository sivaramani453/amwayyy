provider "aws" {
  region = var.region
}

locals {
  private_subnets     = ["subnet-0d7140904d36edf3e","subnet-0ff404b1646a97608"]
  public_subnets     = ["subnet-06cfa40b539b69622","subnet-08c91bbe81412f647"]
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.19"
  subnets         = local.private_subnets

  tags = {
    Environment = "DEV"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
    ApplicationID = "APP3150571"
    DataClassification = "internal"
  }

  vpc_id        = var.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp3"
    key_name         = aws_key_pair.amway-microservices-dev.key_name
  }

  worker_groups = [
    {
      name                          = "${var.cluster_name}-standard-worker"
      instance_type                 = "m5.xlarge"
      asg_desired_capacity          = var.standard_workers_count
      asg_min_size                  = 3
      asg_max_size                  = 20
      tags = [
        {
          key                 = "Environment"
          value               = "Dev"
          propagate_at_launch = true
        },
        {
          key                 = "Project"
          value               = "amway"
          propagate_at_launch = true
        },
        {
          key                 = "DataClassification"
          value               = "internal"
          propagate_at_launch = true
        },
        {
          key                 = "SEC-INFRA-13"
          value               = "Appliance"
          propagate_at_launch = true
        },
        {
          key                 = "SEC-INFRA-14"
          value               = "MSP"
          propagate_at_launch = true
        },
        {
          key                 = "ITAM-SAM"
          value               = "MSP"
          propagate_at_launch = true
        },
        {
          key                 = "ApplicationID"
          value               = "APP3150571"
          propagate_at_launch = true
        }
      ] 
    },
  ]

  enable_irsa                          = "false"
  manage_aws_auth                      = "true"
  attach_worker_cni_policy             = "true"
  cluster_endpoint_private_access      = "true"
  cluster_endpoint_private_access_cidrs = [ "10.0.0.0/8" ]
  cluster_endpoint_public_access       = "false"
  worker_create_cluster_primary_security_group_rules = "true"
  map_roles                            = var.map_roles
  worker_additional_security_group_ids = [aws_security_group.frankfurt_eks-v3-workers.id]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
