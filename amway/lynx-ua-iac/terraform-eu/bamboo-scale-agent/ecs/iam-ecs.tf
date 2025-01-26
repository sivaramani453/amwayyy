resource "aws_iam_instance_profile" "bamboo_scale_agent_iam_profile" {
  name = "${var.ecs_service_name}-iam-profile"
  role = module.bamboo_scale_agent_iam_role.this_iam_role_name
}

module "bamboo_scale_agent_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  create_role = true

  role_name         = "${var.ecs_service_name}-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.bamboo_scale_agent_ssm_policy.arn,
    module.bamboo_scale_agent_cloudwatchlog_policy.arn,
    module.bamboo_scale_agent_ec2_access_policy.arn,
    module.bamboo_scale_agent_iam_access_policy.arn,
  ]
  number_of_custom_role_policy_arns = 4

  tags = local.amway_common_tags
}

module "bamboo_scale_agent_ssm_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "BSA-SSM-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the bamboo scale agent to access ssm"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
               "ssm:PutParameter",
               "ssm:GetParameter",
               "ssm:GetParameters",
               "ssm:DeleteParameter",
               "ssm:DeleteParameters"
            ],
            "Resource": [
               "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/i-*"
            ]
        }
    ]
}
EOF
}

module "bamboo_scale_agent_cloudwatchlog_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "BSA-CloudWatchLog-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the bamboo scale agent to acces cloudwatch logs"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF
}

module "bamboo_scale_agent_ec2_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "BSA-EC2-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the bamboo scale agent to access ec2"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
             "ec2:Describe*",
             "ec2:RebootInstances",
             "ec2:TerminateInstances",
             "ec2:RequestSpotInstances",
             "ec2:ImportKeyPair",
             "ec2:CreateKeyPair",
             "ec2:CreateTags",
             "ec2:StopInstances",
             "ec2:CancelSpotInstanceRequests",
             "ec2:StartInstances",
             "ec2:RunInstances",
             "ec2:DeleteKeyPair",
             "ec2:AssociateIamInstanceProfile",
             "ec2:ReplaceIamInstanceProfileAssociation"
          ],
          "Resource": [
              "*"
         ]
        }
    ]
}
EOF
}

module "bamboo_scale_agent_iam_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "BSA-IAM-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the bamboo scale agent to access iam"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
                "iam:PassRole"
           ],
          "Resource": [
             "${module.bamboo_scale_agent_instance_iam_role.this_iam_role_arn}"
         ]
        }
    ]
}
EOF
}
