data "aws_iam_policy_document" "dynamodb_policy_mcrsrv_template" {
  statement {
    sid = "VisualEditor0"

    effect = "Allow"

    actions = [
      "dynamodb:GetShardIterator",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:GetRecords",
    ]

    resources = [
      "arn:aws:dynamodb:${var.region}:860702706577:table/${var.table_prefix}/index/*",
      "arn:aws:dynamodb:${var.region}:860702706577:table/${var.table_prefix}/stream/*",
    ]
  }

  statement {
    sid    = "VisualEditor1"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:DeleteTable",
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:UpdateTable"
    ]
    resources = ["arn:aws:dynamodb:${var.region}:860702706577:table/${var.table_prefix}"]
  }

  statement {
    sid    = "VisualEditor2"
    effect = "Allow"
    actions = [
      "dynamodb:ListTables",
      "dynamodb:DescribeLimits"
    ]
    resources = ["*"]
  }
}
