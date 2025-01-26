module "lambda_function" {
  source = "../../modules/lambda"

  filename      = "${path.module}/src/app.zip"
  function_name = "LdapClientQA"
  handler       = "index.handler"
  runtime       = "nodejs12.x"
  timeout       = "10"

  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]

  statement_id = "AllowAPIGatewayInvoke"
  principal    = "apigateway.amazonaws.com"
  arn          = "${aws_api_gateway_deployment.lambda_deployment.execution_arn}/POST/*"

  env_vars = {
    LDAP_ADDR     = "my-ldap-addr"
    LDAP_USER     = "mhd"
    LDAP_PASSWORD = "secert_password"
  }
}
