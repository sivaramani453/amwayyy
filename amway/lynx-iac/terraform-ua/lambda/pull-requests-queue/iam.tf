data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_policy" {
  statement {
    sid    = "AllowDynamoDB"
    effect = "Allow"

    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]

    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table}",
    ]
  }

  statement {
    sid    = "AllowSSM"
    effect = "Allow"

    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/locked-${terraform.workspace}*",
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-pr-queue-${terraform.workspace}-iam-policy"
  path        = "/"
  description = "Policy for lambda func to allow work with dynamodb and ssm parameter store"

  policy = "${data.aws_iam_policy_document.allow_policy.json}"
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${module.lambda.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}
