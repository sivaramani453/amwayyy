module "argocd" {
  source                            = "../../components/k8s-addons/argocd"
  argocd_github_connector_user_name = var.argocd.argocd_github_connector_user_name
  argocd_github_connector_password  = var.argocd.argocd_github_connector_password
  argocd_github_org_url             = var.argocd.argocd_github_org_url
  argocd_server_host                = var.argocd.argocd_server_host
  argocd_ingress_enabled            = var.argocd.argocd_ingress_enabled
  common_infra_support_arn          = var.common_infra_support_arn
}

module "certmanager" {
  source = "../../components/k8s-addons/cert-manager"
}

module "actions_runner_namespace" {
  source = "../../components/k8s-addons/k8s-namespace"

  namespace = "actions-runner-system"
}

module "actions_runner_controller_auth" {
  source = "../../components/k8s-addons/k8s-secret"

  name      = "actions-runner-controller-auth"
  namespace = "actions-runner-system"
  data      = var.github_auth
  type      = "generic"

  depends_on = [
    module.actions_runner_namespace
  ]
}

module "actions_runner_controller" {
  source         = "../../components/k8s-addons/actions-runner-controller"
  runner_version = "0.6.1"

  depends_on = [
    module.certmanager,
    module.actions_runner_namespace
  ]
}

module "automation_runner_scaleset" {
  source                = "../../components/k8s-addons/actions-runner-scaleset"
  runner_version        = "0.6.1"
  github_auth_secret    = "actions-runner-controller-auth"
  github_config_url     = var.github_config_url
  runner_scale_set_name = var.runner_name
  runner_group          = "Japan"
  min_runners           = 2
  max_runners           = 10
  # container_mode        = {}
  custom_values = "resources/gha-runner.yml"

  depends_on = [
    module.actions_runner_controller,
    module.actions_runner_namespace,
    module.certmanager
  ]
}
