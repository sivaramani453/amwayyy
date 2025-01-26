provider "aws" {
  region = var.region
}

locals {
  private_subnets     = ["subnet-090ace14068f7fd2d","subnet-0f91270951b285c5c","subnet-0014b752d5a3df57e"]
  public_subnets     = ["subnet-03da4f40e26899d32","subnet-027727d7c3da1a49b","subnet-065b49e0853f1e0d0"]
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.19"
  subnets         = local.private_subnets

  tags = {
    Environment = "production"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id        = var.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp3"
    key_name         = aws_key_pair.amway-microservices-production.key_name
  }

  worker_groups = [
    {
      name                          = "${var.cluster_name}-standard-worker"
      instance_type                 = "m5.xlarge"
      asg_desired_capacity          = var.standard_workers_count
      asg_min_size                  = 3
      asg_max_size                  = 10
    },
  ]

  enable_irsa                          = "false"
  manage_aws_auth                      = "true"
  attach_worker_cni_policy             = "true"
  cluster_endpoint_private_access      = "true"
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
