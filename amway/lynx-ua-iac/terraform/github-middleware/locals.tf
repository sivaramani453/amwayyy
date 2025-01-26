locals {
  tags = "${map(
                "Service", "${var.service}"
               )
  }"

  custom_tags_secgroup {
    ApplicationID = "APP3151110"
    Environment   = "Test"
  }

  https_listeners_count = 1

  https_listeners = "${list(
                        map(
                            "certificate_arn", "${var.certificate_arn}",
                            "port", 443
                        )
  )}"

  target_groups_count = 1

  target_groups = "${list(
                        map("name", "${var.service}",
                            "backend_protocol", "HTTP",
                            "backend_port", 8888,
                            "slow_start", 0
                        )
  )}"

  target_groups_defaults = "${map(
    "cookie_duration", 86400,
    "deregistration_delay", 300,
    "health_check_interval", 15,
    "health_check_healthy_threshold", 3,
    "health_check_path", "/",
    "health_check_port", "traffic-port",
    "health_check_timeout", 10,
    "health_check_unhealthy_threshold", 3,
    "health_check_matcher", "200",
    "stickiness_enabled", "false",
    "target_type", "instance",
    "slow_start", 0
  )}"
}
