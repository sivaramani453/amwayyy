data "aws_iam_policy_document" "allow_dynamodb" {
  statement {
    sid    = "AllowDynamoDB"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]

    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/actions-${terraform.workspace}",
    ]
  }

  statement {
    sid    = "AllowParameterStoreAccess"
    effect = "Allow"

    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:DeleteParameters",
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/actions-*",
    ]
  }

  statement {
    sid    = "AllowInstanceDescribe"
    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "ec2:RebootInstances",
      "ec2:TerminateInstances",
      "ec2:RequestSpotInstances",
      "ec2:ImportKeyPair",
      "ec2:CreateKeyPair",
      "ec2:CreateTags",
      "ec2:StopInstances",
      "ec2:CancelSpotInstanceRequests",
      "ec2:StartInstances",
      "ec2:RunInstances",
      "ec2:DeleteKeyPair",
    ]

    resources = [
      "*",
    ]
  }

  # statement to allow ecs runners to pass roles to created docker-machines
  statement {
    sid    = "AllowIAMPassRole"
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ga-role.name}",
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "scale-agent-${terraform.workspace}-iam-policy"
  path        = "/"
  description = "Policy for lambda func to allow work with dynamodb"

  policy = "${data.aws_iam_policy_document.allow_dynamodb.json}"
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${module.lambda.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}
