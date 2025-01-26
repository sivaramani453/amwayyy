data "template_file" "aws_lambda_es_policy" {
  template = "${file("${path.module}/templates/policy.json.tpl")}"

  vars = {
    es_arn = "${aws_elasticsearch_domain.epam-elasticsearch.arn}"
  }
}

# POLICIES
resource "aws_iam_policy" "lambda_policy" {
  name        = "curator-es-iam-policy"
  path        = "/"
  description = "Policy for lambda func to clean old docs in es"

  policy = "${data.template_file.aws_lambda_es_policy.rendered}"
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${module.lambda_function.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}
