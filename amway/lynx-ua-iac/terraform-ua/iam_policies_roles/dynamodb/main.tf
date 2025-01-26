resource "aws_iam_policy" "policydocument" {
  name        = var.policy_name
  path        = "/"
  description = "Restriction access to DynamoDBTable"
  policy      = data.aws_iam_policy_document.dynamodb_policy_mcrsrv_template.json

}

resource "aws_iam_role" "DynamoDB_role" {
  name = var.role_name


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })


  tags = {
    Name = "Microservice role"
  }
}

resource "aws_iam_policy_attachment" "terraform-attachment" {
  name       = "Terraform  attachment"
  roles      = [aws_iam_role.DynamoDB_role.name]
  policy_arn = aws_iam_policy.policydocument.arn
  depends_on = [aws_iam_policy.policydocument]
}
