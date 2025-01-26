provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "external-dns-aws" {
  count = var.cluster-exist
  source = "cookielab/external-dns-aws/kubernetes"
  version = "0.11.0"

  domains = [ "ru.eia.amway.net" ]

  sources = [ "ingress" ]

  owner_id = "${var.cluster_name}-external-dns"
  aws_iam_policy_name = "${var.cluster_name}_external_dns"
  aws_iam_role_for_policy = module.eks.worker_iam_role_arn
}

module "cert-manager" {
  source  = "basisai/cert-manager/helm"
  version = "0.1.1"
  chart_namespace = "kube-system"
}

module "alb-ingress-controller" {
  count = var.cluster-exist
  source  = "cookielab/alb-ingress-controller/kubernetes"
  version = "0.10.0"

  aws_region = var.region
  aws_vpc_id = var.vpc_id
  kubernetes_cluster_name = var.cluster_name
  aws_iam_role_for_policy = module.eks.worker_iam_role_name

  kubernetes_deployment_image_tag = "v1.1.3"
}

#module "eks-node-problem-detector" {
#  source  = "lablabs/eks-node-problem-detector/aws"
#  version = "0.4.0"
#  settings = {
#    "resources.limits.cpu" : "50m"
#    "resources.limits.memory" : "50Mi"
#    "resources.requests.cpu" : "15m"
#    "resources.requests.memory" : "50Mi"
#  }
#}

resource "kubernetes_namespace" "rancher" {
  metadata {
    name = "cattle-system"
  }
}
