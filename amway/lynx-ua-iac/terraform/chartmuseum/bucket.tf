resource "aws_s3_bucket" "app-backend" {
  bucket        = "${data.terraform_remote_state.core.project}-${var.service}-backend"
  acl           = "private"
  force_destroy = "false"

  tags = "${merge(local.amway_common_tags, local.tags, local.data_tags)}"
}

data "aws_iam_policy_document" "bucket-policy-doc" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    principals = {
      type        = "AWS"
      identifiers = ["${aws_iam_role.ecs-task-role.arn}"]
    }

    resources = [
      "${aws_s3_bucket.app-backend.arn}/*",
      "${aws_s3_bucket.app-backend.arn}",
    ]
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = "${aws_s3_bucket.app-backend.id}"
  policy = "${data.aws_iam_policy_document.bucket-policy-doc.json}"
}
