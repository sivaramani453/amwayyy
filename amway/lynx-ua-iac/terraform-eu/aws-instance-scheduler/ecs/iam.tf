module "instance_scheduler_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  create_role = true

  role_name         = "${var.ecs_service_name}-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.instance_scheduler_lb_policy.arn,
    module.instance_scheduler_cloudwatchlog_policy.arn,
    module.instance_scheduler_ec2_access_policy.arn,
    module.instance_scheduler_dynamodb_access_policy.arn,
    module.instance_scheduler_kms_policy.arn,
  ]
  number_of_custom_role_policy_arns = 5

  tags = local.amway_common_tags
}

module "instance_scheduler_kms_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "InSch-KMS-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the instance scheduler to acces kms"


  policy = <<EOF
{
"Version" : "2012-10-17",
"Statement" : [
    {
         "Effect" : "Allow",
         "Action" : [
             "kms:Decrypt"
         ],
         "Resource" : [
             "${var.instance_scheduler_kms_arn}"
          ]
      }
]
}
EOF
}

module "instance_scheduler_lb_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "InSch-LB-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the instance scheduler to acces loadbalancer"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
		"elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      		"elasticloadbalancing:DeregisterTargets",
      		"elasticloadbalancing:Describe*",
      		"elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      		"elasticloadbalancing:RegisterTargets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

module "instance_scheduler_cloudwatchlog_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "InSch-CloudWatchLog-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the instance scheduler to acces cloudwatch logs"

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

module "instance_scheduler_ec2_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "InSch-EC2-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the instance scheduler to access ec2"

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
            "Resource": [
                "arn:aws:ec2:*:*:instance/*"
            ]
        },
        {
          "Sid": "VisualEditor1",
          "Effect": "Allow",
          "Action": [
             "ec2:DescribeInstances"
          ],
          "Resource": [
              "*"
         ]
        }
    ]
}
EOF
}


module "instance_scheduler_dynamodb_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "InSch-DynamoDB-${var.ecs_service_name}"
  path        = "/"
  description = "Policy for the instance scheduler to access dynamodb"

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
      		"dynamodb:Query",
      		"dynamodb:UpdateItem",
      		"dynamodb:DescribeTable",
      		"dynamodb:GetItem"
            ],
            "Resource": [
                "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.instance_scheduler_config_table_name}",
		"${module.instance_scheduler_dynamodb_users_table.this_dynamodb_table_arn}",
		"${module.instance_scheduler_dynamodb_groups_table.this_dynamodb_table_arn}",
		"${module.instance_scheduler_dynamodb_default_schedule_table.this_dynamodb_table_arn}"
            ]
        },
        {
          "Sid": "VisualEditor1",
          "Effect": "Allow",
          "Action": [
             "dynamodb:ListTables"
          ],
          "Resource": [
              "*"
         ]
        }
    ]
}
EOF
}
