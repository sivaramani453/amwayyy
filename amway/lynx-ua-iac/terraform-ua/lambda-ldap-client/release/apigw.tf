# ################################################## #
# NOTE: the order of this objects EXTREMLY IMPORTANT #
# ################################################## #

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "template_file" "aws_apigw_resource_policy" {
  template = "${file("${path.module}/templates/resource-policy.json")}"

  vars {
    vpc_endpoint = "${data.terraform_remote_state.core.frankfurt.vpc_endpoint.id}"
    account_id   = "${data.aws_caller_identity.current.account_id}"
    aws_region   = "${data.aws_region.current.name}"
  }
}

# Main api gw object
resource "aws_api_gateway_rest_api" "ldap" {
  name        = "LdapClientQA"
  description = "Terraform managed dev ldap client integration"

  endpoint_configuration {
    types = ["PRIVATE"]
  }

  policy = "${data.template_file.aws_apigw_resource_policy.rendered}"
}

# Base resource
resource "aws_api_gateway_method" "post_method" {
  depends_on = ["aws_api_gateway_rest_api.ldap"]

  rest_api_id   = "${aws_api_gateway_rest_api.ldap.id}"
  resource_id   = "${aws_api_gateway_rest_api.ldap.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  depends_on = ["aws_api_gateway_method.post_method"]

  rest_api_id = "${aws_api_gateway_rest_api.ldap.id}"
  resource_id = "${aws_api_gateway_method.post_method.resource_id}"
  http_method = "${aws_api_gateway_method.post_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${module.lambda_function.invoke_arn}"
}

resource "aws_api_gateway_deployment" "lambda_deployment" {
  depends_on = ["aws_api_gateway_integration.lambda"]

  rest_api_id = "${aws_api_gateway_rest_api.ldap.id}"
  stage_name  = "ldap"
}
