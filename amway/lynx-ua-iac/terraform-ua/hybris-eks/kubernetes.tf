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

  domains = [ "hybris.eia.amway.net" ]

  sources = [ "ingress", "service" ]

  owner_id = "${var.cluster_name}-external-dns"
  aws_iam_policy_name = "${var.cluster_name}_external_dns"
  aws_iam_role_for_policy = module.eks.worker_iam_role_name
  
  depends_on = [module.eks]
}

module "cert-manager" {
  source  = "basisai/cert-manager/helm"
  version = "0.1.3"
  chart_namespace = "kube-system"
}

resource "kubernetes_namespace" "rancher" {
  metadata {
    name = "cattle-system"
  }
}
