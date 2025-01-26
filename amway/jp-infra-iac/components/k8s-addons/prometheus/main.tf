resource "helm_release" "prometheus" {
  count            = var.enabled ? 1 : 0
  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "prometheus"
  create_namespace = true
  atomic           = true
  values = [
    templatefile("${path.module}/resources/prometheus-values.yaml",
      {
        serviceAccount = var.serviceAccount,
        roleArn        = var.roleArn,
        remoteWriteUrl = var.remoteWriteUrl,
        region         = var.region,
  })]
}
