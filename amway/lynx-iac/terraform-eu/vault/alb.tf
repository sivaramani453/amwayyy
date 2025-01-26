module "vault_cluster_lb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.9.0"

  name               = "${terraform.workspace}-backend"
  load_balancer_type = "application"
  internal           = true
  subnets            = local.core_subnet_ids
  security_groups    = [module.vault_cluster_sg_lb.security_group_id]
  idle_timeout       = 120
  vpc_id             = data.aws_vpc.vpc.id

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = local.lb_certificate_arn
      ssl_policy      = local.lb_ssl_policy

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
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
  }

  # additional_target_group_attachments = {
  #   ex-instance-other = {
  #     for_each         = local.core_subnet_ids
  #     target_group_key = "ex-instance"
  #     target_type      = "instance"
  #     target_id        = module.vault_cluster.ids[each.key]
  # #     port             = "80"
  # #   }
  # }


  tags = local.amway_common_tags

}

resource "aws_lb_target_group_attachment" "vault_backend" {
  for_each         = local.core_subnet_ids
  # count            = length(local.core_subnet_ids)
  target_group_arn = module.vault_cluster_lb.target_groups.ex-instance.arn
  target_id        = each.value
}
