resource "helm_release" "komodor" {
  name       = "komodor"
  repository = "https://helm-charts.komodor.io"
  chart      = "k8s-watcher"

  atomic           = true
  namespace        = var.namespace
  create_namespace = true

  set {
    name  = "namespace"
    value = var.namespace
  }
  set {
    name  = "createNamespace"
    value = "false"
  }
  set {
    name  = "watcher.actions.basic"
    value = "true"
  }
  set {
    name  = "watcher.actions.advanced"
    value = "true"
  }
  set {
    name  = "watcher.actions.podExec"
    value = "true"
  }
  set {
    name  = "metrics.enabled"
    value = "true"
  }
  set {
    name  = "apiKey"
    value = var.komodor_api_key
  }
  set {
    name  = "watcher.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "watcher.enableHelm"
    value = "true"
  }
  set {
    name  = "watcher.enableActions"
    value = "true"
  }
  set {
    name  = "watcher.resources.secret"
    value = "true"
  }
  set {
    name  = "wather.resources.job"
    value = "true"
  }
  set {
    name  = "watcher.resources.cronjob"
    value = "true"
  }
}
