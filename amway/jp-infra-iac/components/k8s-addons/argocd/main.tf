resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.kubernetes_argocd_namespace
  }
}

resource "helm_release" "argocd" {
  depends_on = [
    kubernetes_namespace.argocd
  ]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.kubernetes_argocd_namespace
  version    = var.argocd_helm_chart_version == "" ? null : var.argocd_helm_chart_version

  values = [
    templatefile(
      "${path.module}/resources/values.yaml.tpl",
      {
        "argocd_server_host"       = var.argocd_server_host
        "common_infra_support_arn" = var.common_infra_support_arn

        "argocd_ingress_enabled"                 = var.argocd_ingress_enabled
        "argocd_ingress_tls_acme_enabled"        = var.argocd_ingress_tls_acme_enabled
        "argocd_ingress_ssl_passthrough_enabled" = var.argocd_ingress_ssl_passthrough_enabled
        "argocd_ingress_class"                   = var.argocd_ingress_class
        "argocd_ingress_tls_secret_name"         = var.argocd_ingress_tls_secret_name
      }
    )
  ]
}


resource "kubernetes_secret_v1" "argocd_github_connector" {
  metadata {
    name      = "amway-common-github-creds"
    namespace = var.kubernetes_argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
    annotations = {
      "managed-by" = "argocd.argoproj.io"
    }
  }

  data = {
    username = var.argocd_github_connector_user_name
    password = var.argocd_github_connector_password
    type     = "git"
    url      = var.argocd_github_org_url
  }

  type = "Opaque"
}
