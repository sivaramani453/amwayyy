resource "kubernetes_config_map" "configmap" {
  metadata {
    name      = var.configmap_name
    namespace = var.namespace
  }

  data = var.configmap_data

  binary_data = var.configmap_binary_data
}
