resource "aws_iam_instance_profile" "bamboo_scale_agent_instance_iam_profile" {
  name = "${var.ecs_service_name}-instance-iam-profile"
  role = module.bamboo_scale_agent_instance_iam_role.this_iam_role_name
}

module "bamboo_scale_agent_instance_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "${var.ecs_service_name}-instance-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.bamboo_scale_agent_instance_ssm_policy.arn,
    module.bamboo_scale_agent_instance_ec2_access_policy.arn,
  ]
  number_of_custom_role_policy_arns = 2

  tags = local.amway_common_tags
}

module "bamboo_scale_agent_instance_ssm_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "BSA-InstProf-SSM-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the bamboo scale agent instance profile to access ssm"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
               "ssm:GetParameter",
               "ssm:GetParameters"
            ],
            "Resource": [
               "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/i-*",
               "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/prepared-ci-update-snapshot*"
            ]
        }
    ]
}
EOF
}

module "bamboo_scale_agent_instance_ec2_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "BSA-InstProf-EC2-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the bamboo scale agent instance profile to access ec2"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
             "ec2:DetachVolume",
             "ec2:AttachVolume",
             "ec2:DeleteVolume",
             "ec2:DescribeInstances",
             "ec2:DescribeVolumes",
             "ec2:DeleteTags",
             "ec2:CreateTags",          
             "ec2:CreateVolume"
          ],
          "Resource": [
              "*"
         ]
        }
    ]
}
EOF
}
