locals {
  https_listeners_count = 2

  https_listeners = "${list(
    map(
	  "certificate_arn", "arn:aws:acm:eu-central-1:860702706577:certificate/3bce1dc0-e691-4521-9fca-4f5430776282", 
	  "port", 443,
	  "target_group_index", 0),
	map(
	  "certificate_arn", "arn:aws:acm:eu-central-1:860702706577:certificate/3bce1dc0-e691-4521-9fca-4f5430776282", 
	  "port", 8083,
	  "target_group_index", 1)
  )}"

  target_groups_count = 2

  target_groups = "${list(
    map("name", "${var.ec2_name}",
      "backend_protocol", "HTTP",
      "backend_port", "8081",
      "slow_start", 0),
	map("name", "${var.ec2_name}-docker",
      "backend_protocol", "HTTP",
      "backend_port", "8083",
      "slow_start", 0)
  )}"

  tags = "${map(
    "Name", "${var.ec2_name}",
    "Service", "${var.ec2_name}",
    "Environment", "epam",
  )}"

  target_groups_defaults = "${map(
    "cookie_duration", 86400,
    "deregistration_delay", 300,
    "health_check_interval", 15,
    "health_check_healthy_threshold", 3,
    "health_check_port", "traffic-port",
    "health_check_timeout", 10,
    "health_check_unhealthy_threshold", 3,
    "health_check_matcher", "200",
    "stickiness_enabled", "false",
    "target_type", "instance",
    "slow_start", 0
    )
  }"
}
