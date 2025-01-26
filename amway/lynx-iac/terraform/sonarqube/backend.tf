terraform {
  backend "s3" {
    bucket = "amway-terraform-states"
    key    = ""
    region = "eu-central-1"
  }
}
