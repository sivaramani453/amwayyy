output "instance_scheduler_repository_arn" {
  value = aws_ecr_repository.instance_scheduler_ecr_repo.arn
}

output "instance_scheduler_repository_url" {
  value = aws_ecr_repository.instance_scheduler_ecr_repo.repository_url
}
