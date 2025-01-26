data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ec2-lambda-allow" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:UpdateFunctionCode",
    ]

    resources = [
      "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:*:*",
    ]
  }
}

resource "aws_iam_policy" "ec2-lambda-allow" {
  name        = "ec2-role-allow-lambda-gitlub-runner"
  description = "Allow ec2 instance to access lambda funcs"
  policy      = "${data.aws_iam_policy_document.ec2-lambda-allow.json}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-lambda-a" {
  role       = "${module.gitlab-runner-a.gitlab_runner_workers_role_name}"
  policy_arn = "${aws_iam_policy.ec2-lambda-allow.arn}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-lambda-b" {
  role       = "${module.gitlab-runner-b.gitlab_runner_workers_role_name}"
  policy_arn = "${aws_iam_policy.ec2-lambda-allow.arn}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-lambda-c" {
  role       = "${module.gitlab-runner-c.gitlab_runner_workers_role_name}"
  policy_arn = "${aws_iam_policy.ec2-lambda-allow.arn}"
}
