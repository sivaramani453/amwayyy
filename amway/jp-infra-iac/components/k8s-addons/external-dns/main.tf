resource "helm_release" "external-dns" {
  count      = var.enabled ? 1 : 0
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"
  atomic     = true
  values = [
    templatefile("${path.module}/resources/values.yaml",
      {
        domainFilters = var.domainFilters,
        txtOwnerId    = var.txtOwnerId,
        rolArn        = var.roleArn,
  })]
}
