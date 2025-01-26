module "runner_container_repo" {
  source        = "../../../../bases/automation-runner-ecr"
  ecr_repo_name = var.ecr_repo_name
}
