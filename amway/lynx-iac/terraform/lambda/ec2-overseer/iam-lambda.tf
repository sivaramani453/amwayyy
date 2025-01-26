# POLICY DOCUMENT
data "aws_iam_policy_document" "allow_ec2_describe" {
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
}

# POLICIES
resource "aws_iam_policy" "lambda_policy" {
  name        = "describe-instances-ec2-ro-amway-policy"
  path        = "/"
  description = "Policy for lambda to get information from instances"

  policy = "${data.aws_iam_policy_document.allow_ec2_describe.json}"
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${module.lambda_function.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}
