locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]

  kube_subnet_cidrs = [
    "${data.aws_subnet.kube-a.cidr_block}",
    "${data.aws_subnet.kube-b.cidr_block}",
    "${data.aws_subnet.kube-c.cidr_block}",
  ]

  kube_subnet_ids = [
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_c.id}",
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

  amway_common_tags = "${map(
         "Terraform", "True",
         "Evironment", "PROD",
         "ApplicationID", "${terraform.workspace}"
 )}"

  amway_ec2_specific_tags = "${map(
     "DataClassification", "EC2",
     "SEC-INFRA-13", "Null",
     "SEC-INFRA-14", "Null"  

 )}"

  amway_ebs_specific_tags = "${map(
    "DataClassification", "EBS"
  )}"
}
