locals {
  additional_policy {
    lynx    = 1
    lynx-ru = 1
    lynx-ci = 1
    default = 1
  }
}

resource "aws_iam_role" "ga-role" {
  name = "ga-instance-role-${terraform.workspace}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ga-machine-profile" {
  name = "ga-instance-profile-${terraform.workspace}"
  role = "${aws_iam_role.ga-role.name}"
}

data "aws_iam_policy_document" "ga-docker-machine" {
  statement {
    sid    = "AllowParameterStoreAccess"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/actions-*",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/prepared-ci-update-snapshot*",
    ]
  }

  statement {
    sid    = "AllowS3Access"
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::amway-dev-allure-reports",
      "arn:aws:s3:::amway-dev-allure-reports/*",
    ]
  }
}

data "aws_iam_policy_document" "ga-terraform-agent" {
  statement {
    sid    = "AllowAllEC2"
    effect = "Allow"

    actions = [
      "ec2:*",
      "route53:*",
      "elasticloadbalancing:*",
      "iam:GetRole",
      "iam:PassRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowListS3"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::amway-terraform-states",
    ]
  }

  statement {
    sid    = "AllowPutGetS3"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::amway-terraform-states/*",
    ]
  }

  statement {
    sid    = "AllowTerraformLocks"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]

    resources = [
      "arn:aws:dynamodb:eu-central-1:860702706577:table/amway-terraform-lock",
    ]
  }
}

resource "aws_iam_policy" "ga-machine-policy" {
  name        = "ga-instance-policy-${terraform.workspace}"
  path        = "/"
  description = "Policy for docker macjine spawned for github actions"

  policy = "${data.aws_iam_policy_document.ga-docker-machine.json}"
}

resource "aws_iam_policy" "ga-terraform-agent-policy" {
  #count       = "${terraform.workspace == "lynx" ? 1 : 0}"
  count       = "${lookup(local.additional_policy, terraform.workspace, 0)}"
  name        = "ga-terraform-agent-policy-${terraform.workspace}"
  path        = "/"
  description = "Policy for lynx agent spawned by actions"

  policy = "${data.aws_iam_policy_document.ga-terraform-agent.json}"
}

resource "aws_iam_role_policy_attachment" "ga-machine-polict-attachment" {
  role       = "${aws_iam_role.ga-role.name}"
  policy_arn = "${aws_iam_policy.ga-machine-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "ga-terraform-agent-attachment" {
  #count      = "${terraform.workspace == "lynx" ? 1 : 0}"
  count      = "${lookup(local.additional_policy, terraform.workspace, 0)}"
  role       = "${aws_iam_role.ga-role.name}"
  policy_arn = "${aws_iam_policy.ga-terraform-agent-policy.arn}"
}
