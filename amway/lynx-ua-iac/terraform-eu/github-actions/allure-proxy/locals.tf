locals {
  core_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_b_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_c_id,
  ]

  nat_gw_ips = [
    "18.198.28.84/32",
    "35.157.159.179/32",
    "3.126.177.142/32"
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  lb_certificate_arn = "arn:aws:acm:eu-central-1:744058822102:certificate/7e5d643b-d9eb-4dcb-9587-5c96ad02c19a"
  lb_ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"


  http_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = local.lb_certificate_arn
      ssl_policy         = local.lb_ssl_policy
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name_prefix          = "allure"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled  = true
        path     = "/status"
        protocol = "HTTP"
        matcher  = "200"
      }
    }
  ]

  amway_common_tags = {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }

  amway_ec2_tags = {
    Schedule           = "running"
    DataClassification = "Internal"
    SEC-INFRA-13       = "Appliance"
    SEC-INFRA-14       = "MSP"
    ITAM-SAM           = "MSP"
  }

  amway_data_tags = {
    DataClassification = "Internal"
  }
}
