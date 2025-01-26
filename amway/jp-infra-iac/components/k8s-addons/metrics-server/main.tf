resource "helm_release" "metrics_server" {
  count            = var.enabled ? 1 : 0
  name             = var.helm_chart_name
  chart            = var.helm_chart_release_name
  repository       = var.helm_chart_repo
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = true
  values = [
    yamlencode(var.settings)
  ]

}
