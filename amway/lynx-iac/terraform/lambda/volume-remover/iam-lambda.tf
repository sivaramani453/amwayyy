# VOLUMES POLICY DOCUMENT
data "aws_iam_policy_document" "allow_ec2_describe_delete_volumes" {
  statement {
    sid    = "AllowDescribeDeleteVolumes"
    effect = "Allow"

    actions = [
      "ec2:DescribeVolumes",
      "ec2:DeleteVolume",
    ]

    resources = [
      "*",
    ]
  }
}

# CLOUDTRAIL POLICY DOCUMENT
data "aws_iam_policy_document" "allow_cloudtrail_lookup_events" {
  statement {
    sid    = "AllowCloudTrailLookupEvents"
    effect = "Allow"

    actions = [
      "cloudtrail:LookupEvents",
    ]

    resources = [
      "*",
    ]
  }
}

# POLICIES
resource "aws_iam_policy" "ec2_lambda_policy" {
  name        = "describe-delete-volumes-ec2-rw-amway-policy"
  path        = "/"
  description = "Policy for lambda to obtain information from volumes and to delete filtered volumes"

  policy = "${data.aws_iam_policy_document.allow_ec2_describe_delete_volumes.json}"
}

resource "aws_iam_policy" "cloudtrail_lambda_policy" {
  name        = "lookup-events-cloudtrail-ro-amway-policy"
  path        = "/"
  description = "Policy for lambda to obtain information from CloudTrail events"

  policy = "${data.aws_iam_policy_document.allow_cloudtrail_lookup_events.json}"
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "ec2_lambda_policy_attachment" {
  role       = "${module.lambda_function.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.ec2_lambda_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "cloudtrail_lambda_policy_attachment" {
  role       = "${module.lambda_function.lambda_iam_role_name}"
  policy_arn = "${aws_iam_policy.cloudtrail_lambda_policy.arn}"
}
