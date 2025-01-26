# DynamoDB

resource "aws_dynamodb_table" "vault_dynamodb_table" {
  name           = "${var.vault_dynamodb_table_name}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Path"
  range_key      = "Key"

  attribute = [
    {
      name = "Path"
      type = "S"
    },
    {
      name = "Key"
      type = "S"
    },
  ]

  tags = "${merge(map("Name", "${var.vault_cluster_name}-${var.vault_dynamodb_table_name}"), var.custom_tags_common, var.custom_tags_spec)}"
}
