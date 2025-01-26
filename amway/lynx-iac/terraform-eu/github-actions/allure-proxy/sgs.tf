module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "allure-proxy-alb-sg"
  description = "Security group for allure proxy alb with HTTP and HTTPS ports open"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

module "instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "allure-proxy-instance-sg"
  description = "Security group for allure proxy instance with SSH and HTTP ports open"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}
