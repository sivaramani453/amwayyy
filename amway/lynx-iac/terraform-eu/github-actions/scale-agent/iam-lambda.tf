module "gh_scale_agent_ssm_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "GHSA-SSM-${terraform.workspace}"
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
  version = "~> 3.0"

  name        = "GHSA-EC2-${terraform.workspace}"
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
  version = "~> 3.0"

  name        = "GHSA-IAM-${terraform.workspace}"
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
             "${module.gh_scale_agent_instance_iam_role.this_iam_role_arn}"
         ]
        }
    ]
}
EOF
}

module "gh_scale_agent_dynamodb_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "GHSA-DyanmoDB-${terraform.workspace}"
  path        = "/"
  description = "Policy for the github actions scale agent to access dynamodb"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
             "dynamodb:GetItem",
             "dynamodb:PutItem"
           ],
          "Resource": [
             "${module.gh_scale_agent_dynamodb_table.dynamodb_table_arn}"
         ]
        }
    ]
}
EOF
}
