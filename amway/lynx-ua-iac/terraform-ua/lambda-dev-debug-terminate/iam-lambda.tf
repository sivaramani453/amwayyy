# POLICY DOCUMENT
data "aws_iam_policy_document" "allow_ec2_describe_terminate" {
  statement {
    sid    = "AllowDescribeInstances"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowTerminateInstances"
    effect = "Allow"

    actions = [
      "ec2:TerminateInstances",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        "dev_ruv*",
        "dev_euv*",
        "dev_aiu*",
        "dev_plu*",
      ]
    }
  }
}

# POLICIES
resource "aws_iam_policy" "lambda_policy" {
  name        = "describe-terminate-instances-ec2-isolated-by-tag-amway-policy"
  path        = "/"
  description = "Policy for lambda to obtain information from instances and to terminate filtered instances"

  policy = "${data.aws_iam_policy_document.allow_ec2_describe_terminate.json}"
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${module.lambda_function.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}
