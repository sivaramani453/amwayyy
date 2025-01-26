module "automation_cluster_ingress" {
  source = "../../../../bases/simple-ingress"

  eks_cluster_config = var.eks_cluster_config
  domain_info        = var.domain_info
  nginx_ingress_info = var.nginx_ingress_info
}
