data "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

locals {
  # Take the existing config map, and add the input ones from
  # var.eks_auth_roles; use `distinct` to avoid duplicates
  aws_auth_configmap = {
    mapRoles = yamlencode(distinct(concat(
      yamldecode(data.kubernetes_config_map_v1.aws_auth.data["mapRoles"]),
      var.eks_auth_roles
  ))) }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  force = true
  data  = local.aws_auth_configmap
}

output "aws_auth" {
  value = kubernetes_config_map_v1_data.aws_auth
}
