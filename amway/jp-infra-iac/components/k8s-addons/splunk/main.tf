resource "helm_release" "splunk" {
  name             = "splunk-logging"
  chart            = "splunk-connect-for-kubernetes"
  repository       = "splunk"
  namespace        = shared
  create_namespace = true
  atomic           = true
  values           = [file("${path.module}/resources/values.yaml")]

  dynamic "set" {
    for_each = var.set_list
    content {
      name  = set.key
      value = set.value
    }
  }


}
