output "func_arn" {
  value = "${aws_lambda_function.main.arn}"
}

output "invoke_arn" {
  value = "${aws_lambda_function.main.invoke_arn}"
}

output "log_group_name" {
  value = "/aws/lambda/${aws_lambda_function.main.function_name}"
}

output "lambda_iam_role_name" {
  value = "${aws_iam_role.lambda-role.name}"
}
