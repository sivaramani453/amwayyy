# S3

resource "aws_s3_bucket" "vault_resources" {
  bucket = "${var.vault_s3_resources_bucket_name}"
  region = "${var.region}"

  acl = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "vault-resources-s3-lifecycle-rule"
    enabled = true
    prefix  = "resources/"

    abort_incomplete_multipart_upload_days = 7

    noncurrent_version_expiration {
      days = "7"
    }
  }

  tags = "${merge(map("Name", "${var.vault_cluster_name}-${var.vault_s3_resources_bucket_name}"), var.custom_tags_common, var.custom_tags_spec)}"
}

resource "aws_s3_bucket" "vault_data" {
  bucket = "${var.vault_s3_data_bucket_name}"
  region = "${var.region}"

  acl = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "vault-data-s3-lifecycle-rule"
    enabled = true

    abort_incomplete_multipart_upload_days = 7

    noncurrent_version_expiration {
      days = "7"
    }
  }

  tags = "${merge(map("Name", "${var.vault_cluster_name}-${var.vault_s3_data_bucket_name}"), var.custom_tags_common, var.custom_tags_spec)}"
}
