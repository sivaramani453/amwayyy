resource "helm_release" "actions-runners-controller" {
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts/"
  chart            = "gha-runner-scale-set-controller"
  version          = var.runner_version
  name             = "actions-runner-controller"
  namespace        = "actions-runner-system"
  create_namespace = true
  atomic           = true
}
