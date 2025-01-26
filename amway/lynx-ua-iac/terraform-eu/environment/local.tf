locals {
  env_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_env_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_env_b_id,
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  epam_eu_route53_zone_name = "hybris.eu.eia.amway.net"
  epam_ru_route53_zone_name = "hybris.eia.amway.net"
  epam_ru_route53_zone_id   = "ZNTYJYCMRBH4S"

  route53_countries = toset(["be", "dk", "es", "fi", "nl", "no", "pt", "se", "at", "ch", "co.uk", "ie", "gr", "it", "de", "fr", "ro", "tr", "pl", "cz", "ee", "si", "bg", "hr", "lt", "ua", "hu", "lv", "sk", "co.za", "co.bw", "co.na"])

  lb_certificate_arn = "arn:aws:acm:eu-central-1:744058822102:certificate/b7243948-07c8-4964-b1dd-78ea8b94dc56"
  lb_ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"

  fe_http_tcp_listeners = [
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


  be_http_tcp_listeners = [
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

  be_target_groups = [
    {
      name_prefix          = "benode"
      backend_protocol     = "HTTPS"
      backend_port         = 9002
      target_type          = "instance"
      deregistration_delay = 10
      stickiness = {
        enabled         = true
        cookie_duration = 86400
        type            = "lb_cookie"
      }
      health_check = {
        enabled  = true
        path     = "/hmc/hybris"
        protocol = "HTTPS"
        matcher  = "200"
      }
    }
  ]


  fe_target_groups = [
    {
      name_prefix          = "fenode"
      backend_protocol     = "HTTPS"
      backend_port         = 9002
      target_type          = "instance"
      deregistration_delay = 10
      stickiness = {
        enabled         = true
        cookie_duration = 86400
        type            = "lb_cookie"
      }
      health_check = {
        enabled  = true
        path     = "/hmc/hybris"
        protocol = "HTTPS"
        matcher  = "200"
      }
    }
  ]

  be_tags = {
    zabbix           = "true"
    zabbix_groups    = "${terraform.workspace}-group,aws-discovered-hosts"
    zabbix_templates = "Template OS Linux,Hybris data,Template App Generic Java JMX"
    zabbix_jmx       = "true"
  }

  fe_tags = {
    zabbix           = "true"
    zabbix_groups    = "${terraform.workspace}-group,aws-discovered-hosts"
    zabbix_templates = "Template OS Linux,Hybris data,Template App Generic Java JMX,Template App Apache Tomcat JMX"
    zabbix_jmx       = "true"
  }

  amway_common_tags = {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }

  amway_ec2_tags = {
    ITAM-SAM           = "MSP"
    DataClassification = "Internal"
    SEC-INFRA-13       = "Appliance"
    SEC-INFRA-14       = "MSP"
  }

  amway_data_tags = {
    DataClassification = "Internal"
  }
}

