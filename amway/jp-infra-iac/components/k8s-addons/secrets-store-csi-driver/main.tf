resource "helm_release" "secrets-store-csi-driver" {
  count            = var.enabled ? 1 : 0
  name             = "secrets-store-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart            = "secrets-store-csi-driver"
  namespace        = var.kubernetes_csi_secret_namespace
  create_namespace = true
  version          = var.csi_secret_helm_chart_version == "" ? null : var.csi_secret_helm_chart_version

  set {
    name  = "syncSecret.enabled"
    value = var.syncSecret
  }

  set {
    name  = "enableSecretRotation"
    value = var.enableSecretRotation
  }
}

# Create the ServiceAccount
resource "kubernetes_service_account" "csi_secrets_store_provider_aws" {
  metadata {
    name      = "csi-secrets-store-provider-aws"
    namespace = "kube-system"
  }
}

# Create the ClusterRole
resource "kubernetes_cluster_role" "csi_secrets_store_provider_aws_cluster_role" {
  metadata {
    name = "csi-secrets-store-provider-aws-cluster-role"
  }

  rule {
    api_groups = [
    ""]
    resources = [
    "serviceaccounts/token"]
    verbs = [
    "create"]
  }

  rule {
    api_groups = [
    ""]
    resources = [
    "serviceaccounts"]
    verbs = [
    "get"]
  }

  rule {
    api_groups = [
    ""]
    resources = [
    "pods"]
    verbs = [
    "get"]
  }

  rule {
    api_groups = [
    ""]
    resources = [
    "nodes"]
    verbs = [
    "get"]
  }
}

# Create the ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "csi_secrets_store_provider_aws_cluster_role_binding" {
  metadata {
    name = "csi-secrets-store-provider-aws-cluster-rolebinding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "secrets-store-csi-driver-provider-aws-cluster-role"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "secrets-store-csi-driver-provider-aws"
    namespace = "kube-system"
  }
}


# Create the DaemonSet
resource "kubernetes_daemonset" "csi_secrets_store_provider_aws" {
  metadata {
    name      = "csi-secrets-store-provider-aws"
    namespace = "kube-system"

    labels = {
      app = "csi-secrets-store-provider-aws"
    }
  }

  spec {
    strategy {
      type = "RollingUpdate"
    }

    selector {
      match_labels = {
        app = "csi-secrets-store-provider-aws"
      }
    }

    template {
      metadata {
        labels = {
          app = "csi-secrets-store-provider-aws"
        }
      }

      spec {
        service_account_name = "csi-secrets-store-provider-aws"
        host_network         = false

        container {
          name  = "provider-aws-installer"
          image = "public.ecr.aws/aws-secrets-manager/secrets-store-csi-driver-provider-aws:1.0.r2-50-g5b4aca1-2023.06.09.21.19"

          image_pull_policy = "Always"

          args = [
            "--provider-volume=/etc/kubernetes/secrets-store-csi-providers",
          ]

          resources {
            requests = {
              cpu    = "50m"
              memory = "100Mi"
            }

            limits = {
              cpu    = "50m"
              memory = "100Mi"
            }
          }

          security_context {
            privileged                 = false
            allow_privilege_escalation = false
          }

          volume_mount {
            mount_path = "/etc/kubernetes/secrets-store-csi-providers"
            name       = "providervol"
          }

          volume_mount {
            name              = "mountpoint-dir"
            mount_path        = "/var/lib/kubelet/pods"
            mount_propagation = "HostToContainer"
          }
        }

        volume {
          name = "providervol"
          host_path {
            path = "/etc/kubernetes/secrets-store-csi-providers"
          }
        }

        volume {
          name = "mountpoint-dir"
          host_path {
            path = "/var/lib/kubelet/pods"
            type = "DirectoryOrCreate"
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

