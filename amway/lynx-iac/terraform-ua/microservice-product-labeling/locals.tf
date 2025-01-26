locals {
  pl_tags = "${map(
	"zabbix", "false",
 	"zabbix_groups", "${terraform.workspace}-group,aws-discovered-hosts",
 	"zabbix_templates", "Template OS Linux,Template App Generic Java JMX",
 	"zabbix_jmx", "false",
        "Schedule", "running"
)}"

  custom_tags_common = {
    Terraform     = "True"
    Environment   = "QA"
    ApplicationID = "APP3150571"
  }

  custom_tags_specific = {
    DataClassification = "internal"
    SEC-INFRA-13       = "Appliance"
    SEC-INFRA-14       = "Null"
  }

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]

  core_subnet_ids = [
    "${data.terraform_remote_state.core.subnet.core_a.id}",
    "${data.terraform_remote_state.core.subnet.core_b.id}",
  ]

  pl_target_groups_count = 1

  pl_target_groups = "${list(
			map("name", "${terraform.workspace}-backend",
                            "backend_protocol", "HTTP",
                            "backend_port", 8080,
			    "target_type", "instance",
			    "healthcheck_protocol", "HTTP",
			    "health_check_path", "${var.alb_taget_group_hc_path}",
			    "health_check_matcher", "200",
			    "health_check_port", "${var.alb_taget_group_hc_port}",
			    "stickiness_enabled", "true",
			    "cookie_duration", 86400,
                            "slow_start", 0,
			),
  )}"

  pl_https_listeners_count = 1

  pl_https_listeners = "${list(
                        map(
                            "certificate_arn", "${var.alb_listener_forward_certificate_arn}",
                            "port", 443,
			    "ssl_policy", "${var.alb_security_policy}",
			    "target_group_index", 0,
                        ),
  )}"
}
