module "alb_security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "4.0.0"
  name                = "rancher-alb-sg"
  description         = "Security group for Rancher alb"
  vpc_id              = data.terraform_remote_state.core.outputs.frankfurt_preprod_vpc_id
  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  tags                = local.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.10"

  name            = "rancher-alb"
  internal        = "true"
  security_groups = [module.alb_security_group.security_group_id]

  subnets = local.subnets
  vpc_id  = data.terraform_remote_state.core.outputs.frankfurt_preprod_vpc_id

  listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  https_listeners             = local.https_listeners

  target_groups = [local.ingress_target_group_https]

  tags = local.tags
}

# Add redirect from 80 to 443
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = module.alb.this_lb_id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}

resource "aws_alb_target_group_attachment" "internal_ingress_alb" {
  count            = var.worker_count
  target_group_arn = module.alb.target_group_arns[0]
  target_id        = element(module.kubernetes_cluster.workers_instance_ids, count.index)
}


module "internal_ingress_lb" {
  source = "../modules/aws-nlb/"

  load_balancer_name        = "${var.cluster_name}-ingress-int"
  load_balancer_is_internal = true

  vpc_id  = data.terraform_remote_state.core.outputs.frankfurt_preprod_vpc_id
  subnets = local.subnets

  target_groups_count = 1
  tcp_listeners_count = 1
  tcp_listeners       = [local.ingress_listener]
  target_groups       = [local.ingress_target_group]

  tags = local.tags
}

resource "aws_lb_target_group_attachment" "internal_ingress" {
  count            = var.worker_count
  target_group_arn = module.internal_ingress_lb.aws_lb_target_group_arn
  target_id        = element(module.kubernetes_cluster.workers_instance_ids, count.index)
}

resource "aws_route53_record" "rancher" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "mspreprod.eia.amway.net"
  type    = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }
}
