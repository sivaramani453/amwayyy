data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    effect = "Allow"

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "allow_s3_get_object" {
  statement {
    sid    = "AllowS3GetObject"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::amway-prod-ru-artifactory-bucket",
      "arn:aws:s3:::amway-prod-ru-artifactory-bucket/*",
    ]
  }
}

resource "aws_iam_policy" "address_validation_s3_access" {
  name        = "S3Access-${terraform.workspace}"
  path        = "/"
  description = "Policy for Address Validation cluster to access s3 data bucket"

  policy = "${data.aws_iam_policy_document.allow_s3_get_object.json}"
}

resource "aws_iam_role" "address_validation_iam_role" {
  name               = "${terraform.workspace}-iam-role"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_trust_policy.json}"
}

resource "aws_iam_instance_profile" "address_validation_iam_profile" {
  name = "${terraform.workspace}-iam-profile"
  role = "${aws_iam_role.address_validation_iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "address_validation_s3_access" {
  role       = "${aws_iam_role.address_validation_iam_role.name}"
  policy_arn = "${aws_iam_policy.address_validation_s3_access.arn}"
}
