module "alb_security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "2.9.0"
  name                = "allure-proxy-alb-sg"
  description         = "Security group for allure proxy alb with HTTP and HTTPS ports open"
  vpc_id              = "${data.terraform_remote_state.core.vpc.dev.id}"
  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = "${local.tags}"
}

module "instance_security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "2.9.0"
  name                = "allure-proxy-instance-sg"
  description         = "Security group for allure proxy instance with SSH and HTTP ports open"
  vpc_id              = "${data.terraform_remote_state.core.vpc.dev.id}"
  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = "${local.tags}"
}
