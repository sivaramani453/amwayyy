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
resource "aws_api_gateway_rest_api" "sms" {
  name        = "MicroserviceSMS-UA"
  description = "Terraform managed dev sms microservice prepare"

  endpoint_configuration {
    types = ["PRIVATE"]
  }

  policy = "${data.template_file.aws_apigw_resource_policy.rendered}"
}

resource "aws_api_gateway_model" "payload" {
  rest_api_id  = "${aws_api_gateway_rest_api.sms.id}"
  name         = "payload"
  description  = "a JSON schema to validate body"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title" : "SMS Validation",
  "type" : "object",
  "properties": {
      "country": {
          "type": "string",
          "enum": ["Ukraine"]
      },
      "templateId": {
          "type": "string",
          "pattern": "[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}"
      },
      "language": {
          "type": "string",
          "enum": ["ua", "en", "ru"]
      },
      "phoneNumbers": {
          "type": "array",
          "items": {
             "type": "string"
           },
           "minItems": 1
      },
      "parameters": {
          "type": "object"
      }
  },
  "required": ["country", "templateId", "language", "phoneNumbers"]
}
EOF
}

# Several resources to create desired path
resource "aws_api_gateway_resource" "v1" {
  depends_on = ["aws_api_gateway_rest_api.sms"]

  rest_api_id = "${aws_api_gateway_rest_api.sms.id}"
  parent_id   = "${aws_api_gateway_rest_api.sms.root_resource_id}"
  path_part   = "v1"
}

# Several resources to create desired path
resource "aws_api_gateway_resource" "message-service" {
  depends_on = ["aws_api_gateway_resource.v1"]

  rest_api_id = "${aws_api_gateway_rest_api.sms.id}"
  parent_id   = "${aws_api_gateway_resource.v1.id}"
  path_part   = "message-service"
}

# Several resources to create desired path
resource "aws_api_gateway_resource" "send-message" {
  depends_on = ["aws_api_gateway_resource.message-service"]

  rest_api_id = "${aws_api_gateway_rest_api.sms.id}"
  parent_id   = "${aws_api_gateway_resource.message-service.id}"
  path_part   = "send-message"
}

resource "aws_api_gateway_request_validator" "validate_all" {
  name                        = "validate_all"
  rest_api_id                 = "${aws_api_gateway_rest_api.sms.id}"
  validate_request_body       = true
  validate_request_parameters = true
}

# Base resource
resource "aws_api_gateway_method" "post_method" {
  depends_on = ["aws_api_gateway_resource.send-message"]

  rest_api_id   = "${aws_api_gateway_rest_api.sms.id}"
  resource_id   = "${aws_api_gateway_resource.send-message.id}"
  http_method   = "POST"
  authorization = "NONE"

  request_validator_id = "${aws_api_gateway_request_validator.validate_all.id}"

  request_models = {
    "application/json"                  = "payload"
    "text/plain"                        = "payload"
    "application/x-www-form-urlencoded" = "payload"
  }

  request_parameters = {
    "method.request.header.Content-Type" = true
  }
}

resource "aws_api_gateway_integration" "lambda" {
  depends_on = ["aws_api_gateway_method.post_method"]

  rest_api_id = "${aws_api_gateway_rest_api.sms.id}"
  resource_id = "${aws_api_gateway_method.post_method.resource_id}"
  http_method = "${aws_api_gateway_method.post_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${module.lambda_function.invoke_arn}"
}

resource "aws_api_gateway_deployment" "lambda_deployment" {
  depends_on = ["aws_api_gateway_integration.lambda"]

  rest_api_id = "${aws_api_gateway_rest_api.sms.id}"
  stage_name  = "api"
}
