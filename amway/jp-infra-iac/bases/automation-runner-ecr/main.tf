module "ecr_repo" {
  source        = "../../components/ecr-repository"
  ecr_repo_name = var.ecr_repo_name
}
