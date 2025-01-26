# DO NOT REMOVE THIS FILE!!!

# #Read1st: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account
# #Those are write-only settings, deleting it will not change anything
# #Also it is applied for an AWS account, ie all ApiGWs

# We need to create this only once for an AWS Account

# resource "aws_api_gateway_account" "demo" {
#   cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
# }

# resource "aws_iam_role" "cloudwatch" {
#   name = "api_gateway_cloudwatch_global"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "apigateway.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "cloudwatch" {
#   name = "default"
#   role = aws_iam_role.cloudwatch.id

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "logs:CreateLogGroup",
#                 "logs:CreateLogStream",
#                 "logs:DescribeLogGroups",
#                 "logs:DescribeLogStreams",
#                 "logs:PutLogEvents",
#                 "logs:GetLogEvents",
#                 "logs:FilterLogEvents"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }