resource "aws_ecr_repository" "repository" {
  name = var.ecr_repo_name
  encryption_configuration {
    encryption_type = "KMS"
  }
}
