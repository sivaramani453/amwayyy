terraform {
  required_version = "~> 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
  backend "s3" {
    bucket         = "jpn-automation-prod-tfstate"
    key            = "automation-cluster-prod-addons"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-prod-tfstate"
  }
}

provider "aws" {
  # use as follows when there's a need to deploy resources in us-east-1:
  # resource "aws_acm_certificate" "b" {
  #  ...
  #  providers = {
  #   aws = aws.us-east-1
  #  }
  # }
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "arn:aws:iam::074806990885:role/jpn-automation-prod-deploy"
    session_name = "cicd"
    external_id  = "cicd"
  }

  default_tags {
    tags = var.default_tags
  }
}

data "aws_eks_cluster" "automation_cluster" {
  name = var.eks_cluster_config.name
}

data "aws_eks_cluster_auth" "automation_cluster" {
  name = var.eks_cluster_config.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.automation_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.automation_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.automation_cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.automation_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.automation_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.automation_cluster.token
  }
}
