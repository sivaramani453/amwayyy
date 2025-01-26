eks_cluster_config = {
  name = "jpn-automation"
}

iam_role_name         = "jp-hybris-prd-reconciliation-artifacts"
s3_bucket_name        = "jp-hybris-prd-reconciliation-artifacts"
s3_bucket_name_export = "jpnprdlochybrisexport"

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
      "token.actions.githubusercontent.com:sub" : "repo:AmwayCommon/jp-backorderReconciliation:*"
    }
  }
}]
