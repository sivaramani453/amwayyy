locals {
  custom_tags {
    fqa1 {
      ApplicationID      = "APP1433689"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    fqa2 {
      ApplicationID      = "APP1433689"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    fqa3 {
      ApplicationID      = "APP1433689"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    fqa4 {
      ApplicationID      = "APP1433689"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    fqa5 {
      ApplicationID      = "APP3150571"
      Environment        = "Dev"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "MSP"
      ITAM-SAM           = "MSP"
      Schedule           = "monday-friday_08:00-21:00"
    }

    fqa6 {
      ApplicationID      = "APP3150571"
      Environment        = "Dev"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "MSP"
      ITAM-SAM           = "MSP"
      Schedule           = "monday-friday_08:00-21:00"
    }

    fqa7 {
      ApplicationID      = "APP3150571"
      Environment        = "Dev"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "MSP"
      ITAM-SAM           = "MSP"
      Schedule           = "monday-friday_08:00-21:00"
    }

    fqa8 {
      ApplicationID      = "APP3150571"
      Environment        = "Dev"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "MSP"
      ITAM-SAM           = "MSP"
      Schedule           = "daily_stop_21:00"
    }

    fqa9 {
      ApplicationID      = "APP3150571"
      Environment        = "Dev"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "MSP"
      ITAM-SAM           = "MSP"
      Schedule           = "monday-friday_08:00-21:00"
    }

    fqa10 {
      ApplicationID      = "APP3150571"
      Environment        = "Dev"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "MSP"
      ITAM-SAM           = "MSP"
      Schedule           = "monday-friday_08:00-21:00"
    }

    fqa11 {
      ApplicationID      = "APP3150571"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    sit {
      ApplicationID      = "APP1433689"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    uat {
      ApplicationID      = "APP1433689"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    uat2 {
      ApplicationID      = "APP1433689"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    uat3 {
      ApplicationID      = "APP1433689"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    uat4 {
      ApplicationID      = "APP1433689"
      Environment        = "Test"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "Null"
    }

    uat5 {
      ApplicationID      = "APP3150571"
      Environment        = "Dev"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "MSP"
      ITAM-SAM           = "MSP"
      Schedule           = "monday-friday_08:00-21:00"
    }

    uat6 {
      ApplicationID      = "APP3150571"
      Environment        = "Dev"
      DataClassification = "internal"
      SEC-INFRA-13       = "Appliance"
      SEC-INFRA-14       = "MSP"
      ITAM-SAM           = "MSP"
      Schedule           = "monday-friday_08:00-21:00"
    }
  }

  be_tags = "${map(
    "zabbix", "true",
    "zabbix_groups", "${terraform.workspace}-group,aws-discovered-hosts",
    "zabbix_templates", "Template OS Linux,Hybris data,Template App Generic Java JMX",
    "zabbix_jmx", "true"
  )}"

  fe_tags = "${map(
    "zabbix", "true",
    "zabbix_groups", "${terraform.workspace}-group,aws-discovered-hosts",
    "zabbix_templates", "Template OS Linux,Hybris data,Template App Generic Java JMX,Template App Apache Tomcat JMX",
    "zabbix_jmx", "true"
  )}"

  be_nodes_ips = [
    "${var.ec2_private_ip_be1}",
    "${var.ec2_private_ip_be2}",
  ]

  fe_nodes_ips = [
    "${var.ec2_private_ip_fe1}",
    "${var.ec2_private_ip_fe2}",
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]

  core_subnet_ids = [
    "${data.terraform_remote_state.core.subnet.core_a.id}",
    "${data.terraform_remote_state.core.subnet.core_b.id}",
  ]

  env_subnet_ids = [
    "${data.terraform_remote_state.core.subnet.env_a.id}",
  ]

  be_target_groups_count = 1

  be_target_groups = "${list(
    map("name", "${terraform.workspace}-backend",
      "backend_protocol", "HTTPS",
      "backend_port", 9002,
      "target_type", "instance",
      "healthcheck_protocol", "HTTPS",
      "health_check_path", "${var.alb_taget_group_hc_path}",
      "health_check_matcher", "200",
      "stickiness_enabled", "true",
      "cookie_duration", 86400,
      "slow_start", 0,
    ),
  )}"

  fe_target_groups_count = 2

  fe_target_groups = "${list(
    map("name", "${terraform.workspace}-frontend",
      "backend_protocol", "HTTPS",
      "backend_port", 9002,
      "target_type", "instance",
      "healthcheck_protocol", "HTTPS",
      "health_check_path", "${var.alb_taget_group_hc_path}",
      "health_check_matcher", "200",
      "stickiness_enabled", "true",
      "cookie_duration", 86400,
      "slow_start", 0,
    ),
    map("name", "${terraform.workspace}-frontend-storybook",
      "backend_protocol", "HTTP",
      "backend_port", 9090,
      "target_type", "instance",
      "healthcheck_protocol", "HTTP",
      "health_check_path", "/",
      "health_check_matcher", "200",
      "stickiness_enabled", "true",
      "cookie_duration", 86400,
      "slow_start", 0,
    ),

  )}"

  be_https_listeners_count = 1

  be_https_listeners = "${list(
    map(
      "certificate_arn", "${var.alb_listener_forward_certificate_arn}",
      "port", 443,
      "ssl_policy", "${var.alb_security_policy}",
      "target_group_index", 0,
    ),
  )}"

  fe_https_listeners_count = 1

  fe_https_listeners = "${list(
    map(
      "certificate_arn", "${var.alb_listener_forward_certificate_arn}",
      "port", 443,
      "ssl_policy", "${var.alb_security_policy}",
      "target_group_index", 0,
    ),
  )}"

  fe_storybook_http_tcp_listeners_count = 1

  fe_storybook_http_tcp_listeners = "${list(
    map(
      "port", 9090,
      "protocol", "HTTP",
      "target_group_index", 1,
    ),
  )}"
}
