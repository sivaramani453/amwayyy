data "aws_iam_policy_document" "allow_efs_mount" {
  statement {
    sid    = "AllowEFSMounts"
    effect = "Allow"

    actions = [
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "efs_lambda_policy" {
  name        = "lambda-efs-cleanup-${lower(terraform.workspace)}-efs-iam-policy"
  path        = "/"
  description = "Policy for the lambda which allows access to EFS mount targets"

  policy = "${data.aws_iam_policy_document.allow_efs_mount.json}"
}

resource "aws_iam_role_policy_attachment" "efs_lambda_policy_attachment" {
  role       = "${module.lambda_function.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.efs_lambda_policy.arn}"
}
