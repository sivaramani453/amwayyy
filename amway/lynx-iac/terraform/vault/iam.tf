# POLICY TEMPLATES

data "template_file" "vault_s3_access_policy" {
  template = "${file("${path.module}/policies/vault-s3-access.json.tpl")}"

  vars {
    bucket_name = "${aws_s3_bucket.vault_data.id}"
  }
}

data "template_file" "vault_kms_access_policy" {
  template = "${file("${path.module}/policies/vault-kms-access.json.tpl")}"

  vars {
    region     = "${var.region}"
    account_id = "${var.aws_aweu_account}"
    kms_key_id = "${aws_kms_key.vault_seal.key_id}"
  }
}

data "template_file" "vault_dynamodb_access_policy" {
  template = "${file("${path.module}/policies/vault-dynamodb-access.json.tpl")}"

  vars {
    region     = "${var.region}"
    account_id = "${var.aws_aweu_account}"
    table_name = "${aws_dynamodb_table.vault_dynamodb_table.id}"
  }
}

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

# ROLE 

resource "aws_iam_role" "vault_iam_role" {
  name               = "${var.vault_cluster_name}-iam-role"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_trust_policy.json}"
}

resource "aws_iam_instance_profile" "vault_iam_profile" {
  name = "${var.vault_cluster_name}-iam-profile"
  role = "${aws_iam_role.vault_iam_role.name}"
}

# POLICIES

resource "aws_iam_policy" "vault_s3_access" {
  name        = "VaultS3Access-${var.vault_project_prefix}"
  path        = "/"
  description = "Policy for vault to access s3 data bucket"

  policy = "${data.template_file.vault_s3_access_policy.rendered}"
}

resource "aws_iam_policy" "vault_kms_access" {
  name        = "VaultKMSAccess-${var.vault_project_prefix}"
  path        = "/"
  description = "Policy for vault to access kms seal key"

  policy = "${data.template_file.vault_kms_access_policy.rendered}"
}

resource "aws_iam_policy" "vault_dynamodb_access" {
  name        = "VaultDynamoDBAccess-${var.vault_project_prefix}"
  path        = "/"
  description = "Policy for vault to access dynamodb table for ha coordination"

  policy = "${data.template_file.vault_dynamodb_access_policy.rendered}"
}

# POLICY ATTACHMENTS

resource "aws_iam_role_policy_attachment" "vault_s3_access" {
  role       = "${aws_iam_role.vault_iam_role.name}"
  policy_arn = "${aws_iam_policy.vault_s3_access.arn}"
}

resource "aws_iam_role_policy_attachment" "vault_kms_access" {
  role       = "${aws_iam_role.vault_iam_role.name}"
  policy_arn = "${aws_iam_policy.vault_kms_access.arn}"
}

resource "aws_iam_role_policy_attachment" "vault_dynamodb_access" {
  role       = "${aws_iam_role.vault_iam_role.name}"
  policy_arn = "${aws_iam_policy.vault_dynamodb_access.arn}"
}
