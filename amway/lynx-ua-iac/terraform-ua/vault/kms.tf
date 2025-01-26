# KMS

resource "aws_kms_alias" "vault_seal" {
  name          = "alias/${var.vault_cluster_name}/seal"
  target_key_id = "${aws_kms_key.vault_seal.key_id}"
}

resource "aws_kms_key" "vault_seal" {
  description         = "KMS key used for ${var.vault_cluster_name} seal"
  enable_key_rotation = true
}
