resource "aws_iam_policy" "es-policy" {
  name        = "amway_eks_opensearch"
  path        = "/"
  description = "allow eks woker nodes to write to Opensearch"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "es:ESHttp*",
      "Resource": "arn:aws:es:eu-central-1:728244295542:domain/aws-elasticsearch/*"
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "es-eks-policy-attach" {
  role       = "amway-eks20220706061411029400000009"
  policy_arn = aws_iam_policy.es-policy.arn
}