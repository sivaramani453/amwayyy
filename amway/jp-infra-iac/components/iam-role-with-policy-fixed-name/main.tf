## Create our assume role policy statements
## This needs to be a local variable because we don't know
## how many statements and what statements will be included,
## so we need to account for these input variables without
## breaking the AWS API.

locals {

  default_allowed_policy = length(var.default_principals) > 0 ? [
    {
      Effect = "Allow"
      Principal = {
        Service = var.default_principals
      }
      Action = "sts:AssumeRole"
    }
  ] : []

  aws_principals_policy = [
    for principal in var.aws_principals : {
      Effect = "Allow"
      Principal = {
        AWS = principal
      }
      Action = "sts:AssumeRole"
    }
  ]

  assume_role_policy = {
    Version = "2012-10-17"
    Statement = flatten([
      local.default_allowed_policy,
      local.aws_principals_policy,
      var.federated_statements,
    ])
  }
}

resource "aws_iam_role" "iam_role" {
  name               = var.iam_role_name
  assume_role_policy = jsonencode(local.assume_role_policy)
}


resource "aws_iam_role_policy" "iam_custom_inline_policy" {
  count = length(var.iam_inline_policy_statements) > 0 ? 1 : 0
  name  = "custom_inline_policy"
  role  = aws_iam_role.iam_role.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.iam_inline_policy_statements
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each   = toset(var.iam_policy_arns)
  role       = aws_iam_role.iam_role.name
  policy_arn = each.value
}

output "iam_role" {
  value = aws_iam_role.iam_role
}
