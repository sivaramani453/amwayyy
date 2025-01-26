resource "aws_api_gateway_api_key" "docgen" {
  name = "docgen-eu-key"
}

resource "aws_api_gateway_usage_plan" "docgen-plan" {
  name        = "docgen-eu-plan"
  description = "plan for docgen unlimited"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
    stage  = "${aws_api_gateway_deployment.lambda_deployment.stage_name}"
  }
}

resource "aws_api_gateway_usage_plan_key" "docgen" {
  key_id        = "${aws_api_gateway_api_key.docgen.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.docgen-plan.id}"
}
