resource "kubernetes_secret" "secret" {
  metadata {
    namespace = var.namespace
    name      = var.name
  }

  type = var.type

  data = var.data
}
