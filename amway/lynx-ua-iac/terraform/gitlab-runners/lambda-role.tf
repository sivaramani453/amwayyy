data "aws_iam_policy_document" "ec2-lambda-allow" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
      "lambda:PublishVersion",
      "lambda:UpdateAlias",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "arn:aws:lambda:*:860702706577:*:*",
    ]
  }
}

resource "aws_iam_policy" "ec2-lambda-allow" {
  name        = "ec2-role-allow-lambda-gitlub-runner"
  description = "Allow ec2 instance to access lambda funcs"
  policy      = "${data.aws_iam_policy_document.ec2-lambda-allow.json}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-lambda" {
  role       = "${module.gitlab-runner.gitlab_runner_workers_role_name}"
  policy_arn = "${aws_iam_policy.ec2-lambda-allow.arn}"
}
