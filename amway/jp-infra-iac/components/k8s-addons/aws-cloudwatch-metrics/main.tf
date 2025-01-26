resource "helm_release" "aws_cloudwatch_metrics" {
  name             = "aws-cloudwatch-metrics"
  chart            = "aws-cloudwatch-metrics"
  atomic           = true
  namespace        = "shared"
  create_namespace = true
  repository       = "https://aws.github.io/eks-charts"

  dynamic "set" {
    for_each = var.set_list
    content {
      name  = set.key
      value = set.value
    }
  }

  # values   = ["${module.path}/resources/values.yaml"]
}
