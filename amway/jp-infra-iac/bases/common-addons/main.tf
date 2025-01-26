module "metrics_server" {
  source = "../../components/k8s-addons/metrics-server"
}

module "external-dns" {
  source        = "../../components/k8s-addons/external-dns"
  domainFilters = var.domain_info.route53_zone
  txtOwnerId    = var.domain_info.txtOwnerId
  roleArn       = var.common_infra_support_arn
}

module "secrets-store-csi-driver" {
  source = "../../components/k8s-addons/secrets-store-csi-driver"
}

module "autoscaler" {
  source       = "../../components/k8s-addons/cluster-autoscaler"
  cluster_name = var.eks_cluster_config.name
}
