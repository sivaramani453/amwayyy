resource "helm_release" "runner-scale-set" {
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set"
  version          = var.runner_version
  name             = var.runner_scale_set_name
  namespace        = "actions-runner-system"
  create_namespace = true
  atomic           = true

  set {
    name  = "githubConfigUrl"
    value = var.github_config_url
  }
  set {
    name  = "githubConfigSecret"
    value = var.github_auth_secret
  }

  set {
    name  = "runnerScaleSetName"
    value = var.runner_scale_set_name
  }
  set {
    name  = "runnerGroup"
    value = var.runner_group
  }
  # set {
  #   name  = "containerMode.type"
  #   value = var.container_mode
  # }
  set {
    name  = "minRunners"
    value = var.min_runners
  }
  set {
    name  = "maxRunners"
    value = var.max_runners
  }

  values = var.custom_values != null ? (fileexists(var.custom_values) ? [file(var.custom_values)] : []) : []
}
