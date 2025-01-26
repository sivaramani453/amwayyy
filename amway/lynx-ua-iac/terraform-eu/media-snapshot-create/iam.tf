resource "aws_iam_instance_profile" "ec2_instance_iam_profile" {
  name = "media-create-snapshot-${terraform.workspace}-iam-profile"
  role = module.ec2_instance_iam_role.this_iam_role_name
}

module "ec2_instance_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "media-create-snapshot-${terraform.workspace}-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.ec2_instance_ec2_access_policy.arn,
  ]
  number_of_custom_role_policy_arns = 2

  tags = local.amway_common_tags
}

module "ec2_instance_ec2_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "MDCS-InstProf-EC2-${terraform.workspace}"
  path        = "/"
  description = "Policy for the ec2 instance profile to access ec2"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:DetachVolume",
                "ec2:CreateSnapshot"
            ],
            "Resource": [
                "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:volume/${aws_ebs_volume.media.id}",
                "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/${module.ec2_instance.id[0]}",
                "arn:aws:ec2:*::snapshot/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateSnapshot",
                "ec2:DeleteTags",
                "ec2:CreateTags"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

