resource "aws_lb" "network_loadbalancer" {
  name               = var.load_balancer_name
  internal           = var.load_balancer_is_internal
  load_balancer_type = "network"
  subnets            = var.subnets

  enable_deletion_protection = var.enable_deletion_protection

  ip_address_type = var.ip_address_type

  tags = merge(
    var.tags,
    {
      "Name" = var.load_balancer_name
    },
  )

  timeouts {
    create = var.load_balancer_create_timeout
    delete = var.load_balancer_delete_timeout
    update = var.load_balancer_update_timeout
  }
}

resource "aws_lb_target_group" "target_group" {
  count    = var.target_groups_count
  port     = var.target_groups[count.index]["backend_port"]
  protocol = upper(var.target_groups[count.index]["backend_protocol"])
  vpc_id   = var.vpc_id
  deregistration_delay = lookup(
    var.target_groups[count.index],
    "deregistration_delay",
    var.target_groups_defaults["deregistration_delay"],
  )
  target_type = lookup(
    var.target_groups[count.index],
    "target_type",
    var.target_groups_defaults["target_type"],
  )
  slow_start = lookup(
    var.target_groups[count.index],
    "slow_start",
    var.target_groups_defaults["slow_start"],
  )

  health_check {
    interval = lookup(
      var.target_groups[count.index],
      "health_check_interval",
      var.target_groups_defaults["health_check_interval"],
    )
    path = lookup(
      var.target_groups[count.index],
      "health_check_path",
      var.target_groups_defaults["health_check_path"],
    )
    port = lookup(
      var.target_groups[count.index],
      "health_check_port",
      var.target_groups_defaults["health_check_port"],
    )
    healthy_threshold = lookup(
      var.target_groups[count.index],
      "health_check_healthy_threshold",
      var.target_groups_defaults["health_check_healthy_threshold"],
    )
    unhealthy_threshold = lookup(
      var.target_groups[count.index],
      "health_check_unhealthy_threshold",
      var.target_groups_defaults["health_check_unhealthy_threshold"],
    )
    protocol = upper(
      lookup(
        var.target_groups[count.index],
        "healthcheck_protocol",
        var.target_groups[count.index]["backend_protocol"],
      ),
    )
  }

  stickiness {
    enabled = "false"
    type    = "lb_cookie"
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.target_groups[count.index]["name"]
    },
  )
  depends_on = [aws_lb.network_loadbalancer]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "tcp_listener" {
  load_balancer_arn = aws_lb.network_loadbalancer.arn
  port              = var.tcp_listeners[count.index]["port"]
  protocol          = var.tcp_listeners[count.index]["protocol"]
  count             = var.tcp_listeners_count

  default_action {
    target_group_arn = aws_lb_target_group.target_group[lookup(var.tcp_listeners[count.index], "target_group_index", 0)].id
    type             = "forward"
  }
}

