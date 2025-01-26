locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]

  amway_common_tags = "${map(
         "Terraform", "True",
         "Environment", "${var.amway_env_type}",
         "ApplicationID", "APP3150571"
  )}"

  amway_ec2_specific_tags = "${map(
     "Schedule",    "running",
     "DataClassification", "internal",
     "SEC-INFRA-13", "Appliance",
     "SEC-INFRA-14", "Null"  
  )}"

  amway_ebs_specific_tags = "${map(
    "DataClassification", "internal"
  )}"

  https_listeners_count = 1

  https_listeners = "${list(
                        map(
                            "certificate_arn", "${var.certificate_arn}",
                            "port", 1235
                        )
  )}"

  target_groups_count = 1

  target_groups = "${list(
                        map("name", "${terraform.workspace}-mdms-proxy-server",
						    "target_type", "instance",
                            "backend_protocol", "HTTP",
                            "backend_port", "1235",
                            "slow_start", 0
                        )
  )}"

  tags = "${local.amway_common_tags}"

  target_groups_defaults = "${map(
    "cookie_duration", 86400,
    "deregistration_delay", 300,
    "health_check_interval", 15,
    "health_check_healthy_threshold", 3,
    "health_check_path", "/health",
    "health_check_port", "traffic-port",
    "health_check_timeout", 10,
    "health_check_unhealthy_threshold", 3,
    "health_check_matcher", "200",
    "stickiness_enabled", "false",
    "target_type", "ip",
    "slow_start", 0
  )}"
}
