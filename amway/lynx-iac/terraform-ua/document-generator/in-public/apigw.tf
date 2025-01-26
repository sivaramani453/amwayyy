# ################################################## #
# NOTE: the order of this objects EXTREMLY IMPORTANT #
# ################################################## #

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Main api gw object
resource "aws_api_gateway_rest_api" "doc_gen" {
  name        = "DocumentGeneratorInternet"
  description = "Terraform managed prod docgen prepare"
}

# Base resource
resource "aws_api_gateway_method" "post_method" {
  depends_on = ["aws_api_gateway_rest_api.doc_gen"]

  rest_api_id   = "${aws_api_gateway_rest_api.doc_gen.id}"
  resource_id   = "${aws_api_gateway_rest_api.doc_gen.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

# Proxy root path to lambda func. Note this is NOT AWS_PROXY, so we have to do a little bit more work
resource "aws_api_gateway_integration" "lambda_integration" {
  depends_on = ["aws_api_gateway_method.post_method"]

  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
  resource_id = "${aws_api_gateway_method.post_method.resource_id}"
  http_method = "${aws_api_gateway_method.post_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS"

  uri = "${module.lambda_function.invoke_arn}"
}

# Response for POST methodhat that returns 200 OK
resource "aws_api_gateway_method_response" "response_200" {
  depends_on = ["aws_api_gateway_integration.lambda_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
  resource_id = "${aws_api_gateway_rest_api.doc_gen.root_resource_id}"

  http_method = "${aws_api_gateway_method.post_method.http_method}"
  status_code = "200"

  response_models {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Response for POST methodhat that returns 400 status code
resource "aws_api_gateway_method_response" "response_400" {
  depends_on = ["aws_api_gateway_method_response.response_200"]

  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
  resource_id = "${aws_api_gateway_rest_api.doc_gen.root_resource_id}"

  http_method = "${aws_api_gateway_method.post_method.http_method}"
  status_code = "400"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Response for POST methodhat that returns 401 status code
resource "aws_api_gateway_method_response" "response_401" {
  depends_on = ["aws_api_gateway_method_response.response_400"]

  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
  resource_id = "${aws_api_gateway_rest_api.doc_gen.root_resource_id}"

  http_method = "${aws_api_gateway_method.post_method.http_method}"
  status_code = "401"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Integration response for POST method, we will add here some headers to allow CORS
resource "aws_api_gateway_integration_response" "200_integration" {
  depends_on = ["aws_api_gateway_method_response.response_401"]

  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
  resource_id = "${aws_api_gateway_rest_api.doc_gen.root_resource_id}"

  http_method = "${aws_api_gateway_method.post_method.http_method}"
  status_code = "${aws_api_gateway_method_response.response_200.status_code}"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }
}

# Integration response for POST method, we will add here some headers to allow CORS
resource "aws_api_gateway_integration_response" "400_integration" {
  depends_on = ["aws_api_gateway_integration_response.200_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
  resource_id = "${aws_api_gateway_rest_api.doc_gen.root_resource_id}"

  http_method = "${aws_api_gateway_method.post_method.http_method}"
  status_code = "${aws_api_gateway_method_response.response_400.status_code}"

  selection_pattern = ".*\"httpStatus\": *\"400\".*"
}

# Integration response for POST method, we will add here some headers to allow CORS
resource "aws_api_gateway_integration_response" "401_integration" {
  depends_on = ["aws_api_gateway_integration_response.400_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
  resource_id = "${aws_api_gateway_rest_api.doc_gen.root_resource_id}"

  http_method = "${aws_api_gateway_method.post_method.http_method}"
  status_code = "${aws_api_gateway_method_response.response_401.status_code}"

  selection_pattern = ".*\"httpStatus\": *\"401\".*"
}

# #######################################
# Now OPTIONS method objects one by one #
# #######################################
# We are not using it right now but we will use it later
# so just to be prepared

# For true CORS support we need OPTIONS method but i am pretty sure it is not needed in our case
#resource "aws_api_gateway_method" "options_method" {
#  depends_on = ["aws_api_gateway_integration_response.401_integration"]
#
#  rest_api_id   = "${aws_api_gateway_rest_api.doc_gen.id}"
#  resource_id   = "${aws_api_gateway_rest_api.doc_gen.root_resource_id}"
#  http_method   = "OPTIONS"
#  authorization = "NONE"
#}

# stub for OPTIONS method that will return 200 OK and headers
#resource "aws_api_gateway_integration" "options_integration" {
#  depends_on = ["aws_api_gateway_method.options_method"]
#
#  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
#  resource_id = "${aws_api_gateway_method.post_method.resource_id}"
#  http_method = "${aws_api_gateway_method.options_method.http_method}"
#  type        = "MOCK"
#}

# Response for OPTIONS method that returns 200 OK
#resource "aws_api_gateway_method_response" "response_200_options" {
#  depends_on = ["aws_api_gateway_integration.options_integration"]
#
#  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
#  resource_id = "${aws_api_gateway_method.post_method.resource_id}"
#
#  http_method = "${aws_api_gateway_method.options_method.http_method}"
#  status_code = "200"
#
#  response_models {
#    "application/json" = "Empty"
#  }

#  response_parameters {
#    "method.response.header.Access-Control-Allow-Headers" = true
#    "method.response.header.Access-Control-Allow-Methods" = true
#    "method.response.header.Access-Control-Allow-Origin"  = true
#  }
#}

# Integration response for OPTIONS method, we will add here some headers to allow CORS
#resource "aws_api_gateway_integration_response" "options_integration_response" {
#  depends_on = ["aws_api_gateway_method_response.response_200_options"]
#
#  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
#  resource_id = "${aws_api_gateway_rest_api.doc_gen.root_resource_id}"
#
#  http_method = "${aws_api_gateway_method.options_method.http_method}"
#  status_code = "${aws_api_gateway_method_response.response_200_options.status_code}"
#
#  response_parameters = {
#    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
#    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
#    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
#  }
#}

# Base stage
resource "aws_api_gateway_deployment" "lambda_deployment" {
  # Use this dependency when cors enabled

  # depends_on = ["aws_api_gateway_integration_response.options_integration_response"]

  depends_on = ["aws_api_gateway_integration_response.401_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.doc_gen.id}"
  stage_name  = "generateDocument"
}
