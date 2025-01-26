resource "aws_iam_instance_profile" "dev_debug" {
  name = "dev_debug"
  role = "${aws_iam_role.dev_debug.name}"
}

resource "aws_iam_role" "dev_debug" {
  name        = "dev_debug"
  description = "Simple role for Dev debug instances"
  path        = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
