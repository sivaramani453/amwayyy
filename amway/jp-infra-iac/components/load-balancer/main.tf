resource "aws_lb" "nlb" {
  name               = var.nlb_name
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  tags               = var.extra_tags
}

output "nlb" {
  value = aws_lb.nlb
}
