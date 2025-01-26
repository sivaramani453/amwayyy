output "user_name" {
  value = "${aws_iam_user.dynatrace.name}"
}

output "policy" {
  value = "${aws_iam_policy.base.policy}"
}
