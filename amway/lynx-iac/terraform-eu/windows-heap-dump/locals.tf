locals {
  ci_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_c_id,
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  amway_common_tags = {
    Terraform     = "true"
    Environment   = "DEV"
    Schedule      = "monday-friday_06:00-21:00"
  }

  amway_ec2_tags = {
    Name       = "Windows Hybris Heap Dump Check"
        
  }
}

