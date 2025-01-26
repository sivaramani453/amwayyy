data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "eks-v2/cluster.tfstate"
    region = "eu-central-1"
  }
}

data "aws_iam_policy_document" "allow_ec2_describe" {
  statement {
    sid    = "AllowInstanceDescribe"
    effect = "Allow"

    actions = [
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
      "ec2:DeleteKeyPair",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowIAMPassRole"
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ga-docker-machine-role",
    ]
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2-discovery-iam-policy"
  path        = "/"
  description = "Policy for lambda func to allow describe instances to add to zabbix"

  policy = "${data.aws_iam_policy_document.allow_ec2_describe.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${data.terraform_remote_state.eks.worker_iam_role_name}"
  policy_arn = "${aws_iam_policy.ec2_policy.arn}"
}
