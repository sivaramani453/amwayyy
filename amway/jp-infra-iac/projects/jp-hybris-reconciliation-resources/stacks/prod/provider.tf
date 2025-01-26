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
    bucket         = "jpn-automation-dev-tfstate"
    key            = "jp-hybris-reconciliation-resources-prod"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    #role_arn     = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy"
    role_arn     = "arn:aws:iam::618163872161:role/jpn-prod-cicd-infra-deployment"
    session_name = "automation"
    external_id  = "automation"
  }

  default_tags {
    tags = var.default_tags
  }
}

# data "aws_eks_cluster" "automation_cluster" {
#   name = var.eks_cluster_config.name
# }

# data "aws_eks_cluster_auth" "automation_cluster" {
#   name = var.eks_cluster_config.name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.automation_cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.automation_cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.automation_cluster.token
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.automation_cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.automation_cluster.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.automation_cluster.token
#   }
# }
