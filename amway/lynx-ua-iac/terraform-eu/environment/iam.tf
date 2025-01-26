resource "aws_iam_instance_profile" "node_iam_profile" {
  name = "${terraform.workspace}-iam-profile"
  role = module.node_iam_role.this_iam_role_name
}

module "node_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "${terraform.workspace}-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.node_tags_access_policy.arn,
  ]
  number_of_custom_role_policy_arns = 3

  tags = local.amway_common_tags
}

module "node_tags_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "NodesTags-${terraform.workspace}"
  path        = "/"
  description = "Policy for environments to access tags on nodes"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteTags",
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "ec2:DescribeTags",
            "Resource": "*"
        }
    ]
}
EOF
}
