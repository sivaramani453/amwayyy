locals {
  core_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_b_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_c_id,
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  route53_zone_name = "hybris.eu.eia.amway.net"

  lb_certificate_arn = "arn:aws:acm:eu-central-1:744058822102:certificate/7e5d643b-d9eb-4dcb-9587-5c96ad02c19a"
  lb_ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"

  container = {
    name        = "${var.ecs_service_name}-container"
    image_name  = var.container_image_name
    cpu         = 512
    memory_soft = 1024
    memory_hard = 1024
    port        = 5000
    count       = 1
  }

  amway_common_tags = {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }


  amway_data_tags = {
    DataClassification = "Internal"
  }
}
