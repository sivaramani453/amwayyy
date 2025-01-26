locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "117.232.101.16/28",
    "103.254.24.243/32",
    "167.23.0.0/16",
    "61.95.172.224/27",
    "210.214.87.0/26",
    "220.225.240.0/27",
    "185.128.158.32/28",
    "115.113.127.64/28",
    "217.153.150.197/32",
    "80.190.139.96/28",
    "195.133.241.0/24"  
  ]

  amway_common_tags = {
    "Terraform"     = "True"
    "Environment"   = var.amway_env_type
    "ApplicationID" = "APP3150571"
  }

  amway_ec2_specific_tags = {
    "Schedule"           = "running"
    "DataClassification" = "internal"
    "SEC-INFRA-13"       = "Appliance"
    "SEC-INFRA-14"       = "MSP"
    "ITAM-SAM"           = "MSP"
  }

  amway_ebs_specific_tags = {
    "DataClassification" = "internal"
  }

  amway_efs_specific_tags = "${map(
    "DataClassification", "internal"
  )}"

  amway_rds_specific_tags = {
    "DataClassification" = "internal"
  }
}

