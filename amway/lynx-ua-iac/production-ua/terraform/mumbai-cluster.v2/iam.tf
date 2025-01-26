data "aws_iam_policy_document" "allow_s3" {
  statement {
    sid    = "AllowS3PutAndGet"
    effect = "Allow"

    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
    ]

    resources = [
      "${module.kubernetes-cluster.s3_bucket_arn}",
      "${module.kubernetes-cluster.s3_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "${var.cluster_name}-s3-policy"
  path        = "/"
  description = "Policy for rke user to put etcd backups in s3 bucket"

  policy = "${data.aws_iam_policy_document.allow_s3.json}"
}

resource "aws_iam_user_policy_attachment" "rke-attach" {
  user       = "${var.rke_aws_user}"
  policy_arn = "${aws_iam_policy.s3_policy.arn}"
}
