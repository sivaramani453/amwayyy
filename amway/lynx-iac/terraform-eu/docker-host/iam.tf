resource "aws_iam_instance_profile" "docker_host_iam_profile" {
  name = "${terraform.workspace}-iam-profile"
  role = module.docker_host_iam_role.this_iam_role_name
}

module "docker_host_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "${terraform.workspace}-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.docker_host_ssm_access_policy.arn,
    module.docker_host_deploy_policy.arn,
    module.docker_host_route53_role_access_policy.arn,
    module.docker_host_secretmanager_access_policy.arn
  ]
  number_of_custom_role_policy_arns = 4

  tags = local.amway_common_tags
}


module "docker_host_route53_role_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "DockerHostRoute53Role-${terraform.workspace}"
  path        = "/"
  description = "Policy for the docker host to assume the route53 role in the aws ru hybris dev account"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": [
                "arn:aws:iam::860702706577:role/amway-eu-epam-new-account-iam-role"
            ]
        }
    ]
}
EOF
}


module "docker_host_secretmanager_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "DockerHostSecretManagerAccess-${terraform.workspace}"
  path        = "/"
  description = "Policy for the docker host to access secret manager"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action":[
             "secretsmanager:GetRandomPassword",
             "secretsmanager:GetResourcePolicy",
             "secretsmanager:GetSecretValue",
             "secretsmanager:DescribeSecret",
             "secretsmanager:ListSecrets",
             "secretsmanager:ListSecretVersionIds"
	    ],
            "Resource": [
                "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*-kafka-secrets-*"
            ]
        }
    ]
}
EOF
}

module "docker_host_ssm_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "DockerHostSSMAccess-${terraform.workspace}"
  path        = "/"
  description = "Policy for the docker host to access ssm"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [ 
                 "ssm:PutParameter",
                 "ssm:GetParameter"
             ],
            "Resource": [
                "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/docker_agents/*docker_agent*",
                "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/prepared-ci-update-snapshot*",
                "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/environments/*/current-release"
            ]
        }
    ]
}
EOF
}

module "docker_host_deploy_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "DockerHostDeploy-${terraform.workspace}"
  path        = "/"
  description = "Policy for the docker host to make deployment of an environment"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:*",
                "s3:*",
                "route53:*",
                "ec2:*",
                "elasticloadbalancing:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/amway-terraform-lock"
        }
    ]
}
EOF
}
