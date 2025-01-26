module "linkerd" {
  source    = "../../components/k8s-addons/linkerd"
  namespace = "linkerd"
}

module "prometheus" {
  source         = "../../components/k8s-addons/prometheus"
  roleArn        = var.prometheus.roleArn
  remoteWriteUrl = var.prometheus.remoteWriteUrl
}

module "jaeger" {
  source                 = "../../components/k8s-addons/jaeger"
  elasticsearch_host     = var.jaeger.elasticsearch_host
  elasticsearch_user     = var.jaeger.elasticsearch_user
  elasticsearch_password = var.jaeger.elasticsearch_password
  domain_name            = var.jaeger.ingress_domain_name
}

module "loki" {
  source              = "../../components/k8s-addons/loki"
  ingress_domain_name = var.loki.ingress_domain_name
  cluster_name        = var.eks_cluster_config.name
  depends_on          = [module.linkerd]
}

module "promtail" {
  source     = "../../components/k8s-addons/promtail"
  depends_on = [module.loki]
}

//module "komodor" {
//  source = "../../components/k8s-addons/komodor"
//
//  namespace = "komodor"
//  komodor_api_key = var.komodor_api_key
//  cluster_name = var.eks_cluster_config.name
//}
