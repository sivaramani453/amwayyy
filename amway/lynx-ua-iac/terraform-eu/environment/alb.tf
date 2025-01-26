module "be_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "v5.13.0"

  name               = "${terraform.workspace}-backend"
  load_balancer_type = "application"
  internal           = true
  subnets            = local.env_subnet_ids
  security_groups    = [module.alb_nodes_sg.this_security_group_id]
  idle_timeout       = 120
  vpc_id             = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  http_tcp_listeners = local.be_http_tcp_listeners
  https_listeners    = local.https_listeners
  target_groups      = local.be_target_groups

  tags              = local.amway_common_tags
  lb_tags           = local.amway_common_tags
  target_group_tags = local.amway_common_tags
}

resource "aws_lb_target_group_attachment" "backend" {
  count            = var.ec2_be_instance_count
  target_group_arn = module.be_alb.target_group_arns[0]
  target_id        = element(aws_instance.be_nodes.*.id, count.index)
}

module "fe_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "v5.13.0"

  name               = "${terraform.workspace}-frontend"
  load_balancer_type = "application"
  internal           = true
  subnets            = local.env_subnet_ids
  security_groups    = [module.alb_nodes_sg.this_security_group_id]
  idle_timeout       = 120
  vpc_id             = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  http_tcp_listeners = local.fe_http_tcp_listeners
  https_listeners    = local.https_listeners
  target_groups      = local.fe_target_groups

  tags              = local.amway_common_tags
  lb_tags           = local.amway_common_tags
  target_group_tags = local.amway_common_tags
}

resource "aws_lb_target_group_attachment" "frontend" {
  count            = var.ec2_fe_instance_count
  target_group_arn = module.fe_alb.target_group_arns[0]
  target_id        = element(aws_instance.fe_nodes.*.id, count.index)
}
