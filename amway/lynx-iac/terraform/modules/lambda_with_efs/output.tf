output "func_arn" {
  value = "${element(concat(aws_lambda_function.main.*.arn, aws_lambda_function.from_bucket.*.arn), 0)}"
}

output "invoke_arn" {
  value = "${element(concat(aws_lambda_function.main.*.invoke_arn, aws_lambda_function.from_bucket.*.invoke_arn), 0)}"
}

output "log_group_name" {
  value = "/aws/lambda/${var.function_name}"
}

output "lambda_iam_role_name" {
  value = "${aws_iam_role.lambda-role.name}"
}
