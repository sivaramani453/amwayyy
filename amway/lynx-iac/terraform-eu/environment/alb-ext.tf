locals {

  ext_balancer = ["sit"]

  public_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_public_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_public_b_id,
  ]

  eu_lb_certificate_arn = "arn:aws:acm:eu-central-1:744058822102:certificate/7e5d643b-d9eb-4dcb-9587-5c96ad02c19a"

  https_ext_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = local.eu_lb_certificate_arn
      ssl_policy         = local.lb_ssl_policy
      target_group_index = 0
    },
  ]
}

module "alb_be_nodes_ext_sg" {

  create = contains(local.ext_balancer, terraform.workspace) ? true : false

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "alb-be-ext-${terraform.workspace}-sg"
  description = "Security group for the External ALB of the BE nodes"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = var.ext_balancer_be_acl
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

module "alb_fe_nodes_ext_sg" {

  create = contains(local.ext_balancer, terraform.workspace) ? true : false

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "alb-fe-ext-${terraform.workspace}-sg"
  description = "Security group for the External ALB of the FE nodes"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = var.ext_balancer_fe_acl
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_route53_record" "alb_ext_backend_url" {
  count   = contains(local.ext_balancer, terraform.workspace) ? 1 : 0
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "kony-${terraform.workspace}.${local.epam_eu_route53_zone_name}"
  type    = "A"

  alias {
    name                   = module.be_alb_ext.this_lb_dns_name
    zone_id                = module.be_alb_ext.this_lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb_ext_frontend_url" {
  count   = contains(local.ext_balancer, terraform.workspace) ? 1 : 0
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "mashery-${terraform.workspace}.${local.epam_eu_route53_zone_name}"
  type    = "A"

  alias {
    name                   = module.fe_alb_ext.this_lb_dns_name
    zone_id                = module.fe_alb_ext.this_lb_zone_id
    evaluate_target_health = true
  }
}

module "be_alb_ext" {
  source  = "terraform-aws-modules/alb/aws"
  version = "v5.13.0"

  create_lb = contains(local.ext_balancer, terraform.workspace) ? true : false

  name               = "${terraform.workspace}-ext-backend"
  load_balancer_type = "application"
  internal           = false
  subnets            = local.public_subnet_ids
  security_groups    = [module.alb_be_nodes_ext_sg.this_security_group_id]
  idle_timeout       = 120
  vpc_id             = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  https_listeners = local.https_ext_listeners
  target_groups   = local.be_target_groups

  tags              = local.amway_common_tags
  lb_tags           = local.amway_common_tags
  target_group_tags = local.amway_common_tags
}

resource "aws_lb_target_group_attachment" "backend_ext" {
  count            = contains(local.ext_balancer, terraform.workspace) ? var.ec2_be_instance_count : 0
  target_group_arn = module.be_alb_ext.target_group_arns[0]
  target_id        = element(aws_instance.be_nodes.*.id, count.index)
}

module "fe_alb_ext" {
  source  = "terraform-aws-modules/alb/aws"
  version = "v5.13.0"

  create_lb = contains(local.ext_balancer, terraform.workspace) ? true : false

  name               = "${terraform.workspace}-ext-frontend"
  load_balancer_type = "application"
  internal           = false
  subnets            = local.public_subnet_ids
  security_groups    = [module.alb_fe_nodes_ext_sg.this_security_group_id]
  idle_timeout       = 120
  vpc_id             = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  https_listeners = local.https_ext_listeners
  target_groups   = local.fe_target_groups

  tags              = local.amway_common_tags
  lb_tags           = local.amway_common_tags
  target_group_tags = local.amway_common_tags
}

resource "aws_lb_target_group_attachment" "frontend_ext" {
  count            = contains(local.ext_balancer, terraform.workspace) ? var.ec2_fe_instance_count : 0
  target_group_arn = module.fe_alb_ext.target_group_arns[0]
  target_id        = element(aws_instance.fe_nodes.*.id, count.index)
}
