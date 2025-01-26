module "dynamo_s3_role" {
  source = "../../components/iam-role-with-policy-fixed-name"

  iam_role_name        = "jp-acsd-pss-data-export"
  federated_statements = var.oidc_statement
  iam_inline_policy_statements = [
    {
      "Sid" : "BasicS3",
      "Effect" : "Allow",
      "Action" : [
        "s3:ListStorageLensConfigurations",
        "s3:ListAccessPointsForObjectLambda",
        "s3:GetAccessPoint",
        "s3:PutAccountPublicAccessBlock",
        "s3:GetAccountPublicAccessBlock",
        "s3:ListAllMyBuckets",
        "s3:ListAccessPoints",
        "s3:PutAccessPointPublicAccessBlock",
        "s3:ListJobs",
        "s3:PutStorageLensConfiguration",
        "s3:ListMultiRegionAccessPoints",
        "s3:CreateJob"
      ],
      "Resource" : ["*"]
    },
    {
      "Sid" : "ReconBucketAccess",
      "Effect" : "Allow",
      "Action" : ["s3:*"],
      "Resource" : [
        "arn:aws:s3:::${var.s3_bucket_name}/*",
        "arn:aws:s3:::${var.s3_bucket_name}"
      ]
    },
    {
      "Sid" : "ListAndDescribe",
      "Effect" : "Allow",
      "Action" : [
        "dynamodb:List*",
        "dynamodb:DescribeReservedCapacity*",
        "dynamodb:DescribeLimits",
        "dynamodb:DescribeTimeToLive"
      ],
      "Resource" : ["*"]
    },
    {
      "Sid" : "SpecificTable",
      "Effect" : "Allow",
      "Action" : [
        "dynamodb:BatchGet*",
        "dynamodb:DescribeStream",
        "dynamodb:DescribeTable",
        "dynamodb:Get*",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWrite*",
        "dynamodb:CreateTable",
        "dynamodb:Delete*",
        "dynamodb:Update*",
        "dynamodb:PutItem"
      ],
      "Resource" : ["arn:aws:dynamodb:*:*:table/${var.dynamo_table_name}"]
    }
  ]
}
