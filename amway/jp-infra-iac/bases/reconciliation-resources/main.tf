module "bucket" {
  source         = "../../components/s3-bucket-simple"
  s3_bucket_name = var.s3_bucket_name
  extra_tags = {
    "DataClassification" = "Internal"
  }
}

module "iam_role" {
  source = "../../components/iam-role-with-policy-fixed-name"

  iam_role_name        = var.iam_role_name
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
      "Sid" : "ExportBucketAccess",
      "Effect" : "Allow",
      "Action" : [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObjectAcl",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource" : [
        "arn:aws:s3:::${var.s3_bucket_name_export}/*",
        "arn:aws:s3:::${var.s3_bucket_name_export}"
      ]
    },
    {
      "Sid" : "DenyDelete",
      "Effect" : "Deny",
      "Action" : [
        "s3:DeleteBucketWebsite",
        "s3:DeleteAccessPoint",
        "s3:CreateBucket",
        "s3:DeleteBucket"
      ],
      "Resource" : ["*"]
    }
  ]
}
