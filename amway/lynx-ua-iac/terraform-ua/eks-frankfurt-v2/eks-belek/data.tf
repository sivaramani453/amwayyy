data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = "eu-microservices-preprod-amway-terraform-states"
    key    = "eks-v2/core.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "nlbs" {
  backend = "s3"
  config = {
    bucket = "eu-microservices-preprod-amway-terraform-states"
    key    = "eks-v2/nlbs.tfstate"
    region = "eu-central-1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


data "aws_caller_identity" "current" {}

locals {
  eks_oidc = regex("[A-Z0-9]{32}", data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer)
}
