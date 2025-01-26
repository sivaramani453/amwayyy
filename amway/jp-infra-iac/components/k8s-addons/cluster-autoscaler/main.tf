resource "helm_release" "cluster_autoscaler" {
  name             = "cluster-autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "shared"
  create_namespace = true
  atomic           = true
  repository       = "https://kubernetes.github.io/autoscaler"
  values           = [file("${path.module}/resources/values.yaml")]

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  dynamic "set" {
    for_each = var.set_list
    content {
      name  = set.key
      value = set.value
    }
  }

}
