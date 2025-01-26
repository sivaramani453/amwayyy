resource "helm_release" "grafana" {
  name             = "grafana"
  chart            = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  namespace        = "shared"
  create_namespace = true
  atomic           = true
  values           = [file("${path.module}/resources/values.yaml")]

  dynamic "set" {
    for_each = var.set_list
    content {
      name  = set.key
      value = set.value
    }
  }

}
