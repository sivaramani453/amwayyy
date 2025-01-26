resource "aws_iam_instance_profile" "nexus_iam_profile" {
  name = "nexus-iam-profile"
  role = module.nexus_iam_role.this_iam_role_name
}

module "nexus_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "nexus-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.nexus_s3_access_policy.arn,
  ]
  number_of_custom_role_policy_arns = 1

  tags = local.amway_common_tags
}

module "nexus_s3_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "NexusS3Access-nexus-instance"
  path        = "/"
  description = "Policy for nexus to access the s3 data buckets"

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
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:GetLifecycleConfiguration",
                "s3:PutLifecycleConfiguration",
                "s3:PutObjectTagging",
                "s3:GetObjectTagging",
                "s3:DeleteObjectTagging",
                "s3:GetBucketAcl"
            ],
            "Resource": [
                "${module.nexus_s3_cd_builds.this_s3_bucket_arn}",
                "${module.nexus_s3_cd_builds.this_s3_bucket_arn}/*",
                "${module.nexus_s3_static_files.this_s3_bucket_arn}",
                "${module.nexus_s3_static_files.this_s3_bucket_arn}/*",
                "${module.nexus_s3_docker_files.this_s3_bucket_arn}",
                "${module.nexus_s3_docker_files.this_s3_bucket_arn}/*"
            ]
        }
    ]
}
EOF
}
