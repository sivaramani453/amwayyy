resource "helm_release" "fluent_bit" {
  name             = "fluent-bit"
  chart            = "fluent-bit"
  namespace        = "shared"
  create_namespace = true
  atomic           = true
  repository       = "https://fluent.github.io/helm-charts"
  values = [templatefile("${path.module}/resources/values.yaml",
  { splunk_token = var.splunk_token })]

  dynamic "set" {
    for_each = var.set_list
    content {
      name  = set.key
      value = set.value
    }
  }
}
