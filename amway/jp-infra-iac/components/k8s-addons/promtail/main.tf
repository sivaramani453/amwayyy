resource "helm_release" "promtail" {
  name             = "promtail"
  chart            = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  namespace        = "tracing"
  create_namespace = true
  atomic           = true

  values = [
    templatefile("${path.module}/resources/values.yaml",
      {
        loki_clients_url = var.loki_clients_url
    })
  ]

  dynamic "set" {
    for_each = var.set_list
    content {
      name  = set.key
      value = set.value
    }
  }

}
