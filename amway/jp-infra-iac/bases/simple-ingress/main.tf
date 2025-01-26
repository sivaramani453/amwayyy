module "nginx_ingress_ssl_certificate" {
  source                    = "../../components/regional-ssl-acm"
  domain_name               = var.nginx_ingress_info.domain_name
  subject_alternative_names = var.nginx_ingress_info.subject_alternative_names
  route53_zone              = var.domain_info.route53_zone
}

module "ingress" {
  source = "../../components/k8s-addons/ingress"

  domain_name         = var.nginx_ingress_info.domain_name
  ssl_certificate_arn = module.nginx_ingress_ssl_certificate.acm_certificate.arn
  subnet_ids          = var.eks_cluster_config.subnet_ids
  nlb_name            = var.eks_cluster_config.name

  depends_on = [
    module.nginx_ingress_ssl_certificate
  ]
}

data "aws_lb" "nlb" {
  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_config.name}" = "owned"
  }
  depends_on = [
    module.ingress
  ]
}
