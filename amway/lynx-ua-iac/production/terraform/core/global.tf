resource "aws_route53_zone" "main" {
  name = "ms.eia.amway.net"

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
