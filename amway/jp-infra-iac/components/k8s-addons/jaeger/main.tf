resource "kubernetes_namespace" "linkerd-extension-namespace" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name = "linkerd-jaeger"
  }
}

resource "helm_release" "jaeger" {
  count      = var.enabled ? 1 : 0
  name       = "jaeger"
  chart      = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  namespace  = "linkerd-jaeger"
  atomic     = true

  values = [
    templatefile("${path.module}/resources/values.yaml",
      {
        domain_name            = var.domain_name,
        elasticsearch_host     = var.elasticsearch_host,
        elasticsearch_user     = var.elasticsearch_user,
        elasticsearch_password = var.elasticsearch_password
  })]

  dynamic "set" {
    for_each = var.set_list
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [kubernetes_namespace.linkerd-extension-namespace]
}

resource "helm_release" "linkerd-jaeger" {
  count      = var.enabled ? 1 : 0
  name       = "linkerd-jaeger"
  chart      = "linkerd-jaeger"
  repository = "https://helm.linkerd.io/edge"
  namespace  = "linkerd-jaeger"
  atomic     = true
  version    = "30.10.5-edge"

  values = [
    templatefile("${path.module}/resources/linkerd-jaeger-values.yaml", {
      jaeger_collector_endpoint = var.jaeger_collector_endpoint,
      otlp_collector_endpoint   = var.otlp_collector_endpoint,
    })
  ]

  depends_on = [
    helm_release.jaeger,
  ]
}
