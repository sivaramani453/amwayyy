module "vault_cluster_lb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name               = "${terraform.workspace}-backend"
  load_balancer_type = "application"
  internal           = true
  subnets            = local.core_subnet_ids
  security_groups    = [module.vault_cluster_sg_lb.this_security_group_id]
  idle_timeout       = 120
  vpc_id             = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = local.lb_certificate_arn
      ssl_policy         = local.lb_ssl_policy
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name_prefix          = "vault"
      backend_protocol     = "HTTP"
      backend_port         = 8200
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 5
        path                = "/v1/sys/health"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  tags = local.amway_common_tags

  lb_tags = local.amway_common_tags

  target_group_tags = local.amway_common_tags
}

resource "aws_lb_target_group_attachment" "vault_backend" {
  count            = length(local.core_subnet_ids)
  target_group_arn = module.vault_cluster_lb.target_group_arns[0]
  target_id        = element(module.vault_cluster.id, count.index)
}
