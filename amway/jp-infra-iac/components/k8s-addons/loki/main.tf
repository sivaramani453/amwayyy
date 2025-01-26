locals {
  aws_s3_bucket_name    = var.cluster_name == "" ? "eks-loki-storage-bucket" : "${var.cluster_name}-eks-loki-storage-bucket"
  aws_region_name       = data.aws_region.current.name
  dynamodb_table_prefix = "${var.cluster_name}-loki-index-"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "selected" {
  count = 1
  name  = var.cluster_name
}

data "aws_iam_policy_document" "eks_oidc_assume_role" {
  count = 1
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.selected[0].identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.namespace}:loki-sa"
      ]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.selected[0].identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.chunks.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.chunks.bucket}/*"
    ]
  }
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:ListTagsOfResource",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable",
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:dynamodb:${local.aws_region_name}:${data.aws_caller_identity.current.account_id}:table/${local.dynamodb_table_prefix}*"
    ]
  }
  statement {
    actions = [
      "dynamodb:ListTables"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DeleteScalingPolicy"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.this.name}"
    ]
  }
}

resource "aws_iam_policy" "this" {
  name        = "${var.cluster_name}-loki"
  description = "Permissions that are required by Loki to manage logs."
  policy      = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role" "this" {
  name                  = "${var.cluster_name}-loki"
  description           = "Permissions required by Loki to do it's job."
  force_detach_policies = true

  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}

resource "aws_s3_bucket" "chunks" {
  bucket = local.aws_s3_bucket_name
  acl    = "private"
  versioning {
    enabled = false
  }
}

resource "kubernetes_namespace" "loki-namespace" {
  metadata {
    //    annotations = {
    //      "linkerd.io/inject" = "enabled"
    //    }
    name = var.namespace
  }
}

resource "helm_release" "loki" {
  name             = "loki"
  chart            = "loki-distributed"
  repository       = "https://grafana.github.io/helm-charts"
  namespace        = var.namespace
  create_namespace = true
  atomic           = true

  values = [
    templatefile("${path.module}/resources/values.yaml",
      {
        domain_name              = var.ingress_domain_name,
        storage_region           = local.aws_region_name,
        dynamodb_table_prefix    = local.dynamodb_table_prefix,
        storage_s3_bucket        = aws_s3_bucket.chunks.bucket,
        service_account_role_arn = aws_iam_role.this.arn
  })]

  depends_on = [
    aws_s3_bucket.chunks
  ]
}
