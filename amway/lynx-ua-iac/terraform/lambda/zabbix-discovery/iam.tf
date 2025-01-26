data "aws_iam_policy_document" "allow_ec2_describe" {
  statement {
    sid    = "AllowInstanceDescribe"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-zabbix-discovery-iam-policy"
  path        = "/"
  description = "Policy for lambda func to allow describe instances to add to zabbix"

  policy = "${data.aws_iam_policy_document.allow_ec2_describe.json}"
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${module.lambda_function.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}
