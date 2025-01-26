resource "aws_iam_instance_profile" "vault_iam_profile" {
  name = "${terraform.workspace}-iam-profile"
  role = module.vault_iam_role.this_iam_role_name
}

module "vault_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "${terraform.workspace}-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.vault_s3_access_policy.arn,
    module.vault_kms_access_policy.arn,
    module.vault_dynamodb_access_policy.arn,
  ]
  number_of_custom_role_policy_arns = 3

  tags = local.amway_common_tags
}


module "vault_s3_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "VaultS3Access-${terraform.workspace}"
  path        = "/"
  description = "Policy for vault to access the s3 data bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${module.vault_data.this_s3_bucket_arn}",
                "${module.vault_data.this_s3_bucket_arn}/*"
            ]
        }
    ]
}
EOF
}

module "vault_kms_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "VaultKMSAccess-${terraform.workspace}"
  path        = "/"
  description = "Policy for vault to access the kms seal key"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:ReEncryptTo",
                "kms:GenerateDataKey",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:DescribeKey",
                "kms:ReEncryptFrom"
            ],
            "Resource": [
               "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.vault_seal.key_id}"
            ]
        }
    ] 
}
EOF
}

module "vault_dynamodb_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "VaultDynamoDBAccess-${terraform.workspace}"
  path        = "/"
  description = "Policy for vault to access dynamodb table for ha coordination"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:Scan",
                "dynamodb:ListTagsOfResource",
                "dynamodb:Query",
                "dynamodb:UpdateItem",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:CreateTable",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:GetRecords"
            ],
            "Resource": [
                "${module.vault_dynamodb_table.this_dynamodb_table_arn}",
                "${module.vault_dynamodb_table.this_dynamodb_table_arn}/stream/*"
            ]
        }
    ]
}
EOF
}

