data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ga-role" {
  name = "ga-docker-machine-role"
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
  name = "ga-docker-machine-profile"
  role = "${aws_iam_role.ga-role.name}"
}

data "aws_iam_policy_document" "ga-docker-machine" {
  statement {
    sid    = "AllowLambdaCodeUpdate"
    effect = "Allow"

    actions = [
      "lambda:UpdateFunctionCode",
    ]

    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:MicroserviceSMS",
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:DocumentGeneratorEU",
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:DocumentGeneratorEUPub",
    ]
  }
}

resource "aws_iam_policy" "ga-machine-policy" {
  name        = "ga-machine-policy"
  path        = "/"
  description = "Policy for docker macjine spawned for github actions"

  policy = "${data.aws_iam_policy_document.ga-docker-machine.json}"
}

resource "aws_iam_role_policy_attachment" "ga-machine-polict-attachment" {
  role       = "${aws_iam_role.ga-role.name}"
  policy_arn = "${aws_iam_policy.ga-machine-policy.arn}"
}
