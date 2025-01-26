resource "aws_route53_zone" "main" {
  name = "ru.eia.amway.net"

  tags = {
    Environment   = "PROD"
    Terraform     = "true"
    ApplicationID = "APP3150571"
  }
}
