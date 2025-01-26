# terraform {
#   backend "s3" {
#     encrypt        = true
#     dynamodb_table = "amway-terraform-lock"
#     bucket         = "dev-eu-amway-terraform-states"
#     key            = "bamboo-gh-scale-agent-v2.tfstate"
#     region         = "eu-central-1"
#   }
# }
