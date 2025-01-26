data "aws_iam_policy_document" "allow_ec2_describe_delete_snapshots" {
  statement {
    sid    = "AllowDescribeSnapshots"
    effect = "Allow"

    actions = [
      "ec2:DescribeSnapshots",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowDeleteSnapshots"
    effect = "Allow"

    actions = [
      "ec2:DeleteSnapshot",
    ]

    resources = [
      "arn:aws:ec2:*::snapshot/*",
    ]
  }
}

resource "aws_iam_policy" "ec2_lambda_policy" {
  name        = "describe-delete-snapshots-ec2-rw-amway-policy"
  path        = "/"
  description = "Policy for lambda to obtain information from snapshots and to delete filtered snapshots"

  policy = "${data.aws_iam_policy_document.allow_ec2_describe_delete_snapshots.json}"
}

resource "aws_iam_role_policy_attachment" "ec2_lambda_policy_attachment" {
  role       = "${module.lambda_function.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.ec2_lambda_policy.arn}"
}
