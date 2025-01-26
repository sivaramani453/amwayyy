data "aws_iam_policy_document" "sqs_policy_mcrsrv_template" {
  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    actions   = ["sqs:ListQueues"]
    resources = ["*"]
  }

  statement {
    sid       = "VisualEditor1"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = ["arn:aws:sqs:eu-central-1:860702706577:pii-test-ru-sqs-test"]
  }
}
