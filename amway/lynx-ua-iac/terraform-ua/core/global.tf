resource "aws_route53_zone" "main" {
  name          = "hybris.eia.amway.net."
  comment       = ""
  force_destroy = false

  tags = {
    Terraform = "true"
  }
}
