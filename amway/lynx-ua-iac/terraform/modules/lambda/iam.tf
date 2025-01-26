# POLICY TEMPLATES
data "template_file" "lambda_trust_policy" {
  template = "${file("${path.module}/policies/lambda-trust-policy.json")}"
}

data "template_file" "aws_lambda_vpc_policy" {
  template = "${file("${path.module}/policies/lambda-vpc-policy.json")}"
}

# ROLE 
resource "aws_iam_role" "lambda-role" {
  name               = "${var.function_name}-lambda-role"
  assume_role_policy = "${data.template_file.lambda_trust_policy.rendered}"
}

# POLICIES
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.function_name}-policy"
  path        = "/"
  description = "Policy for lambda logs and vpc access"

  policy = "${data.template_file.aws_lambda_vpc_policy.rendered}"
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${aws_iam_role.lambda-role.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}
