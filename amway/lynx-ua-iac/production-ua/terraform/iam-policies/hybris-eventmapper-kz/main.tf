resource "aws_iam_policy" "hybris-eventmapper-kz" {
  name        = "hybris-eventmapper-kz"
  path        = "/"
  description = "Range access to dynamodb table"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
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
          "dynamodb:GetShardIterator",
          "dynamodb:GetItem",
          "dynamodb:UpdateTable",
          "dynamodb:GetRecords"
        ],
        "Resource" : "arn:aws:dynamodb:eu-central-1:645993801158:table/hybrisevents-kz"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:ListTables",
          "dynamodb:DescribeLimits"
        ],
        "Resource" : "*"
      }
    ]
  })
}
