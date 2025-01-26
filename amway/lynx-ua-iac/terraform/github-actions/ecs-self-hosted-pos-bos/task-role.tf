resource "aws_iam_role" "ecs-ga-role" {
  name = "ecs-task-role-${var.cluster_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = "${merge(local.amway_common_tags, local.tags)}"
}

data "aws_iam_policy_document" "ecs-policy-doc" {
  # statement to allow ecs runners to have access to some parameters and exchange tokens
  # only parameters with cluster name prifix are allowed
  statement {
    sid    = "AllowLambdaCodeUpdate"
    effect = "Allow"

    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.cluster_name}-*",
    ]
  }
}

resource "aws_iam_policy" "ecs-policy" {
  name        = "${var.cluster_name}-policy"
  path        = "/"
  description = "Policy for github actions runners in ecs"

  policy = "${data.aws_iam_policy_document.ecs-policy-doc.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-ga-policy-attach" {
  role       = "${aws_iam_role.ecs-ga-role.name}"
  policy_arn = "${aws_iam_policy.ecs-policy.arn}"
}
