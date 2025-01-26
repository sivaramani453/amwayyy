oidc_statement = [{
  "Effect" : "Allow",
  "Principal" : {
    "Federated" : "arn:aws:iam::618163872161:oidc-provider/token.actions.githubusercontent.com"
  },
  "Action" : "sts:AssumeRoleWithWebIdentity",
  "Condition" : {
    "StringEquals" : {
      "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
    },
    "StringLike" : {
      "token.actions.githubusercontent.com:sub" : "repo:AmwayCommon/jp-acsd-batch-jobs:*"
    }
  }
}]

iam_role_name     = "jp-acsd-pss-data-export"
dynamo_table_name = "jp-itdd-pss-info"

# Technically this s3 bucket is in a different AWS account and the IAM permission
# will be useless...
s3_bucket_name = "apac-amway-dfx-api-studioabo"


