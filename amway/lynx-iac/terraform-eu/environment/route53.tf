resource "aws_route53_record" "be_nodes_urls" {
  # provider = aws.epam_ru
  count    = var.ec2_be_instance_count
  zone_id  = data.terraform_remote_state.core.outputs.route53_zone_id
  name     = "be${count.index + 1}-${terraform.workspace}.${local.epam_eu_route53_zone_name}"
  ttl      = "300"
  type     = "A"

  records = [element(aws_instance.be_nodes.*.private_ip, count.index)]
}

resource "aws_route53_record" "fe_nodes_urls" {
  # provider = aws.epam_ru
  count    = var.ec2_fe_instance_count
  zone_id  = data.terraform_remote_state.core.outputs.route53_zone_id
  name     = "fe${count.index + 1}-${terraform.workspace}.${local.epam_eu_route53_zone_name}"
  ttl      = "300"
  type     = "A"

  records = [element(aws_instance.fe_nodes.*.private_ip, count.index)]
}

resource "aws_route53_record" "alb_backend_url" {
  # provider = aws.epam_ru
  zone_id  = data.terraform_remote_state.core.outputs.route53_zone_id
  name     = "admin-${terraform.workspace}.${local.epam_eu_route53_zone_name}"
  type     = "A"

  alias {
    name                   = module.be_alb.this_lb_dns_name
    zone_id                = module.be_alb.this_lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb_frontend_url" {
  # provider = aws.epam_ru
  for_each = local.route53_countries
  zone_id  = data.terraform_remote_state.core.outputs.route53_zone_id
  name     = "${terraform.workspace}.${each.key}.${local.epam_eu_route53_zone_name}"
  type     = "A"

  alias {
    name                   = module.fe_alb.this_lb_dns_name
    zone_id                = module.fe_alb.this_lb_zone_id
    evaluate_target_health = true
  }
}


# resource "aws_acm_certificate" "cert" {
#   domain_name       = "*.hybris.eu.eia.amway.net"
#   validation_method = "DNS"

#   subject_alternative_names = [
#   for i in local.route53_countries: 
#        "*.${i}.hybris.eu.eia.amway.net"
#   ]
#   tags  = {
#     "ApplicationID" = "APP1433689"
#     "Environment"   = "DEV" 
#     "Name"          = "amway-eu-environments-subdomain-certificate"
#     "Terraform"     = "True" 
#     }
#   options {
#     certificate_transparency_logging_preference = "ENABLED"
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }
