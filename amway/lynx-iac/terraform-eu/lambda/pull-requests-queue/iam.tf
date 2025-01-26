module "pr_queue_dynamodb_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "PRQueueDynamoDBAccess-${terraform.workspace}"
  path        = "/"
  description = "Policy for the pr queue to access dynamodb table for ha coordination"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:UpdateItem",
                "dynamodb:CreateTable",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem"
            ],
            "Resource": [
               "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table}"           
            ]
        }
    ]
}
EOF
}

module "pr_queue_ssm_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "PRQueueSSMAccess-${terraform.workspace}"
  path        = "/"
  description = "Policy for the pr queue to access ssm"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
               "ssm:GetParameter",
               "ssm:PutParameter"
              ],
            "Resource": [
               "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/locked-${terraform.workspace}*"
            ]
        }
    ]
}
EOF
}
