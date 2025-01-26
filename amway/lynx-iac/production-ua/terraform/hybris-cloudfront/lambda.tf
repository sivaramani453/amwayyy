provider "aws" {
  alias = "edge_region"
  region = "us-east-1"
}

locals {
  origin_request_lambda  = "ModifyRequestOriginCF-${terraform.workspace}"
  origin_response_lambda = "SetCacheControlForHybrisCF-${terraform.workspace}"
}

resource "aws_iam_role" "lambda_role" {

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "lambda_logging" {
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "archive_file" "origin_response_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/origin_response.js"
  output_path = "origin_response_lambda.zip"
}

resource "aws_lambda_function" "origin_response_lambda" {
  provider      = aws.edge_region
  description   = "Set CacheControl for viewers to 24h for specific mime types"
  filename      = data.archive_file.origin_response_lambda.output_path
  function_name = local.origin_response_lambda
  role          = aws_iam_role.lambda_role.arn
  handler       = "origin_response.handler"

  source_code_hash = filebase64sha256(data.archive_file.origin_response_lambda.output_path)

  runtime = "nodejs12.x"
  
  publish = true
  tags = {
    Terraform = "True"
    Evironment = var.waf_enabled ? "DEV" : "PROD"
    DataClassification = "Internal"
    ApplicationID = "APP3150571"
    Name = "SetCacheControlForHybrisCF"
  }
  depends_on    = [aws_iam_role_policy_attachment.lambda_logs]
}

data "archive_file" "origin_request_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/origin_request.js"
  output_path = "origin_request_lambda.zip"
}

resource "aws_lambda_function" "origin_request_lambda" {
  provider      = aws.edge_region
  description   = "Proxy bots to prerender service based on User-Agent"
  filename      = data.archive_file.origin_request_lambda.output_path
  function_name = local.origin_request_lambda
  role          = aws_iam_role.lambda_role.arn
  handler       = "origin_request.handler"

  source_code_hash = filebase64sha256(data.archive_file.origin_request_lambda.output_path)

  runtime = "nodejs12.x"

  publish = true
  tags = {
    Terraform = "True"
    Evironment = var.waf_enabled ? "DEV" : "PROD"
    DataClassification = "Internal"
    ApplicationID = "APP3150571"
    Name = "ModifyRequestOriginCF"
  }
  depends_on    = [aws_iam_role_policy_attachment.lambda_logs]
}