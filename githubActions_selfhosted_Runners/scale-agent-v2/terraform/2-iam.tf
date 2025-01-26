######## IAM Policies ######################

module "gh_scale_agent_ssm_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-SSM-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent to access ssm"


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
               "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/actions-*"
            ]
        }
    ]
}
EOF
}

module "gh_scale_agent_ssm_sqs_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-SSM-${terraform.workspace}-SQS"
  path        = "/"
  description = "Policy for the github actions scale agent to access ssm"


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
               "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/actions-*"
            ]
        }
    ]
}
EOF
}


module "gh_scale_agent_ec2_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-EC2-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent to access ec2"

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

module "gh_scale_agent_iam_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-IAM-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent to access iam"

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
             "${module.gh_scale_agent_instance_iam_role.iam_role_arn}"
         ]
        }
    ]
}
EOF
}


module "gh_scale_agent_sqs_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-SQS-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent to access sqs"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Action": [
              "sqs:DeleteMessage",
              "sqs:ReceiveMessage",
              "sqs:GetQueueAttributes"
          ],
          "Resource": "${aws_sqs_queue.webhook_queue.arn}",
          "Effect": "Allow"
      },
      {
        "Effect": "Allow",
        "Action": "sqs:ListQueues",
        "Resource": "*"
      }      
    ]
  }
EOF
}

module "gh_scale_agent_sqs_publish_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-SQS-Publish-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent to publish sqs"

#"Resource": "${aws_sqs_queue.webhook_queue.arn}",

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Action": [
              "sqs:*"
          ],
          "Resource": "${aws_sqs_queue.webhook_queue.arn}",
          "Effect": "Allow"
      },
      {
        "Effect": "Allow",
        "Action": "sqs:ListQueues",
        "Resource": "*"
      }      
    ]
  }
EOF
}

##############################################################################

resource "aws_iam_instance_profile" "gh_scale_agent_instance_iam_profile" {
  name = "gh-scale-agent-v2-${terraform.workspace}-instance-iam-profile"
  role = module.gh_scale_agent_instance_iam_role.iam_role_name
}

module "gh_scale_agent_instance_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.37.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "gh-scale-agent-v2-${terraform.workspace}-instance-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.gh_scale_agent_instance_ssm_policy.arn,
    module.gh_scale_agent_instance_ec2_access_policy.arn,
    module.gh_scale_agent_instance_s3_policy.arn,
    module.gh_scale_agent_instance_dynamodb_access_policy.arn,
    module.gh_scale_agent_instance_cloudwatch_access_policy.arn,
    module.gh_scale_agent_instance_cloudwatch_logs_access_policy.arn,
    module.gh_scale_agent_instance_ecr_access_access_policy.arn,
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  number_of_custom_role_policy_arns = 8

  tags = local.common_tags
}

module "gh_scale_agent_instance_s3_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-InstProf-S3-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent instance profile to access s3"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
               "s3:*"
            ],
            "Resource": [
               "arn:aws:s3:::amway-dev-eu-allure-reports",
               "arn:aws:s3:::amway-dev-eu-allure-reports/*"
            ]
        }
    ]
}
EOF
}

module "gh_scale_agent_instance_ssm_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-InstProf-SSM-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent instance profile to access ssm"


  # "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/update-ci-node14-list",
  # ^ add this resource for lynx

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
               "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/update-ci-node14-list",
               "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/actions-*",
               "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/prepared-ci-update-snapshot*"
            ]
        }
    ]
}
EOF
}

module "gh_scale_agent_instance_ec2_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-InstProf-EC2-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github acrtions scale agent instance profile to access ec2"

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
             "ec2:CreateVolume",
             "ec2:DescribeTags"
          ],
          "Resource": [
              "*"
         ]
        }
    ]
}
EOF
}


# the policy below is required by GH Action plugin that checks mapping from GH User to AmwayID
module "gh_scale_agent_instance_dynamodb_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-InstProf-DynamoDB-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent instance profile to access DynamoDB"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "TerraformGithubactionsScaleagentV2",
          "Effect": "Allow",
          "Action": [
             "dynamodb:GetItem"
          ],
          "Resource": [
              "*"
         ]
        }
    ]
}
EOF
}

# the policy below is required for CloudWatch Agent to collect logs and metrics
module "gh_scale_agent_instance_cloudwatch_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-InstProf-CloudWatch-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent instance profile to log stuff to CloudWatch"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "TerraformGithubactionsScaleagentV2",
          "Effect": "Allow",
          "Action": [
             "cloudwatch:*"
          ],
          "Resource": [
              "*"
         ]
        }
    ]
}
EOF
}


# the policy below is required for CloudWatch Agent to collect logs and metrics
module "gh_scale_agent_instance_cloudwatch_logs_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-InstProf-CloudWatch-Logs-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent instance profile to log stuff to CloudWatch"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "TerraformGithubactionsScaleagentV2",
          "Effect": "Allow",
          "Action": [
             "logs:*"
          ],
          "Resource": [
              "*"
         ]
        }
    ]
}
EOF
}

# policy for accessing ECR by selfhoasted runners
module "gh_scale_agent_instance_ecr_access_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.37.0"

  name        = "GHSA-v2-InstProf-ECR-access-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions selfhosted runners to access ECR without logging in"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "TerraformGithubactionsScaleagentV2",
          "Effect": "Allow",
          "Action": [
             "ecr:*"
          ],
          "Resource": [
              "*"
         ]
        }
    ]
}
EOF
}



