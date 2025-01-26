resource "aws_dynamodb_table" "table" {
  name           = "actions-${terraform.workspace}"
  hash_key       = "k"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "k"
    type = "S"
  }

  tags {
    Name = "GitHub actions scale agent ws ${terraform.workspace}"
  }
}
