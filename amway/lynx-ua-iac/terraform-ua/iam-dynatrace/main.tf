data "aws_iam_policy_document" "base" {
  statement {
    sid    = "ReadAccess"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "cloudwatch:GetMetricData",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeInstanceHealth",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetHealth",
      "rds:DescribeDBInstances",
      "rds:DescribeEvents",
      "rds:ListTagsForResource",
      "dynamodb:ListTables",
      "dynamodb:ListTagsOfResource",
      "lambda:ListFunctions",
      "lambda:ListTags",
      "elasticbeanstalk:DescribeEnvironments",
      "elasticbeanstalk:DescribeEnvironmentResources",
      "s3:ListAllMyBuckets",
      "sts:GetCallerIdentity",
      "cloudformation:ListStackResources",
      "tag:GetResources",
      "tag:GetTagKeys",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "base" {
  name        = "amway-dynatrace-readonly-policy"
  path        = "/"
  description = "Policy for Dynatrace monitoring"

  policy = "${data.aws_iam_policy_document.base.json}"
}

resource "aws_iam_user" "dynatrace" {
  name = "amway-dynatrace-readonly"
  path = "/"

  tags = {
    Terraform = "true"
    Service   = "Dynatrace"
  }
}

resource "aws_iam_user_policy_attachment" "attach" {
  user       = "${aws_iam_user.dynatrace.name}"
  policy_arn = "${aws_iam_policy.base.arn}"
}

resource "aws_iam_access_key" "dynatrace" {
  user   = "${aws_iam_user.dynatrace.name}"
  status = "Active"
}
