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
     "SEC-INFRA-14", "MSP",
     "ITAM-SAM", "MSP"
  )}"

  amway_ebs_specific_tags = "${map(
    "DataClassification", "internal"
  )}"

#  amway_efs_specific_tags = "${map(
#    "DataClassification", "internal"
#  )}"

  amway_rds_specific_tags = "${map(
     "DataClassification", "internal"
  )}"
}
