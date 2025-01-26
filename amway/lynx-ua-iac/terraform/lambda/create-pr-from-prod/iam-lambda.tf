data "aws_iam_policy_document" "allow_ssm_access" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:DeleteParameters",
    ]

    resources = [
      "${aws_ssm_parameter.commit_sha_lynx.arn}",
      "${aws_ssm_parameter.commit_sha_lynx_conf.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssm:DescribeParameters",
    ]

    resources = [
      "*",
    ]
  }
}

# POLICIES
resource "aws_iam_policy" "lambda_policy" {
  name        = "create-pr-iam-policy-${terraform.workspace}"
  path        = "/"
  description = "Policy for lambda func to read/write parameters store records"

  policy = "${data.aws_iam_policy_document.allow_ssm_access.json}"
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${module.lambda_function.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}
