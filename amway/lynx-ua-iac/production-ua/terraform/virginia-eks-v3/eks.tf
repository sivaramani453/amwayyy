provider "aws" {
  region = var.region
}

locals {
  private_subnets     = ["subnet-083f450aed702ee1c","subnet-0f8930f23c2374e96","subnet-060b4ddcadb94a42a","subnet-0a5d5f35c9e1a82c3","subnet-0e32a61510c366e04"]
  public_subnets     = ["subnet-0765fd9f1036a514d","subnet-00b99b4e67b6295f9","subnet-01c10bc3b00205652","subnet-01a8446c36e5dcf71","subnet-0a8bc5edd2d54f130","subnet-08c28395661a7c141"]
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
      asg_min_size                  = 2
      asg_max_size                  = 10
    },
  ]

  enable_irsa                          = "false"
  manage_aws_auth                      = "true"
  attach_worker_cni_policy             = "false"
  cluster_endpoint_private_access      = "true"
  cluster_endpoint_public_access       = "false"
  worker_create_cluster_primary_security_group_rules = "true"
  map_roles                            = var.map_roles
  worker_additional_security_group_ids = [aws_security_group.virginia_eks-v3-workers.id]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
