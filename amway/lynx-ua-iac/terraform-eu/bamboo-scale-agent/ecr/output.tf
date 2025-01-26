output "bamboo_scale_agent_repository_arn" {
  value = aws_ecr_repository.bamboo_scale_agent_repo.arn
}

output "bamboo_scale_agent_repository_url" {
  value = aws_ecr_repository.bamboo_scale_agent_repo.repository_url
}
