resource "aws_iam_instance_profile" "dashboard_iam_profile" {
  name = "dashboard-iam-profile"
  role = module.dashboard_iam_role.this_iam_role_name
}

module "dashboard_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "dashboard-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.dashboard_secret_access_policy.arn,
    module.dashboard_s3_access_policy.arn
  ]
  number_of_custom_role_policy_arns = 2

  tags = local.amway_common_tags
}

module "dashboard_secret_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "DSHBSecretAccess-dashboard"
  path        = "/"
  description = "Policy for dashboard instance to access aws secret storage"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:eu-central-1:744058822102:secret:amway05-01-eu-central-1-dumps-hwYIOv",
                "arn:aws:secretsmanager:eu-central-1:744058822102:secret:git_admin_user_4_enterprise-iAitCx",
		"arn:aws:secretsmanager:eu-central-1:744058822102:secret:ga-builds-ro-credentials-xqGIdt"
            ]
        }
    ]
}
EOF
}

module "dashboard_s3_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "DSHBS3Access-dashboard"
  path        = "/"
  description = "Policy for dashboard instance to access aws s3"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
		"s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_mysql_be_bucket_name}/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
		"s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_mysql_be_bucket_name}"
            ]
        }
    ]
}
EOF
}
