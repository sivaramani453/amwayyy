resource "aws_route53_zone" "main" {
  name = "hybris.eu.eia.amway.net"

  tags = "${local.amway_common_tags}"
}
