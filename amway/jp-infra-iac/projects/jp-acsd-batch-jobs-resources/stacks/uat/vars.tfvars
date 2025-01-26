oidc_statement = [{
  "Effect" : "Allow",
  "Principal" : {
    "Federated" : "arn:aws:iam::417642731771:oidc-provider/token.actions.githubusercontent.com"
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
s3_bucket_name    = "itdd-japan-web-components-dev"
dynamo_table_name = "jp-itdd-pss-info-uat"
