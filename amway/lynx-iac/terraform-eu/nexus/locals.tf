locals {

  amway_common_tags = {
    "Service"       = "Nexus"
    "Terraform"     = "true"
    "ApplicationID" = "APP3151110"
    "Environment"   = "DEV"
  }

  amway_instance_tags = {
    "SEC-INFRA-13" = "Appliance"
    "SEC-INFRA-14" = "MSP"
    "ITAM-SAM"     = "MSP"
    "Schedule"     = "running"
  }

  amway_data_tags = {
    "DataClassification" = "Internal"
  }

  alb_subnets = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_b_id
    # Commented intentionally, I did not forget about it.
    # data.terraform_remote_state.core.outputs.frankfurt_subnet_core_c_id
  ]

  instance_subnets = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_a_id
    # Same as before
  ]

  alb_certificate_arn = "arn:aws:acm:eu-central-1:744058822102:certificate/7e5d643b-d9eb-4dcb-9587-5c96ad02c19a"

  alb_listener_ssl_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  alb_target_groups = [
    {
      "name_prefix"      = "nxsui"
      "backend_protocol" = "HTTP"
      "backend_port"     = "8081"
      "slow_start"       = 0
    },
    {
      "name_prefix"      = "nxsdkr"
      "backend_protocol" = "HTTP"
      "backend_port"     = "8083"
      "slow_start"       = 0
    }
  ]

  alb_https_listeners = [
    {
      port               = 443
      certificate_arn    = local.alb_certificate_arn
      target_group_index = 0
    },
    {
      port               = 8083
      certificate_arn    = local.alb_certificate_arn
      target_group_index = 1
    }
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8"
  ]
}

