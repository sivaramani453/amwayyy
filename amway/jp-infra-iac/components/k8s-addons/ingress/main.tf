# NLB
# ingress controller

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = var.namespace
  create_namespace = true
  atomic           = true

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = var.ssl_certificate_arn
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    value = join("\\,", var.subnet_ids)
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name"
    value = var.nlb_name
  }

  dynamic "set" {
    for_each = var.set_list
    content {
      name  = set.key
      value = set.value
    }
  }

  values = [
    templatefile("${path.module}/resources/values.yaml",
      {
        domain_name = var.domain_name,
        trace_collector_service_account : var.trace_collector_service_account,
        trace_collector : var.trace_collector,
        otlp_collector_host : var.otlp_collector_host,
        otlp_collector_port : var.otlp_collector_port,
    })
  ]
  //  values = fileexists("resources/ingress.yaml") ? [file("resources/ingress.yaml")] : []

}

output "ingress" {
  value = helm_release.nginx_ingress
}
