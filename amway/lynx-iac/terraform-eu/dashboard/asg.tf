resource "aws_launch_template" "instance_lt" {
  name_prefix = "dashboard-eu"

  image_id      = data.aws_ami.instance_ami.id
  instance_type = "t3.small"

  vpc_security_group_ids = [module.instance_sg.this_security_group_id]
  key_name               = data.terraform_remote_state.core.outputs.frankfurt_ssh_key
  ebs_optimized          = true
  user_data              = base64encode(data.template_file.userdata.rendered)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.dashboard_iam_profile.name
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge({ "Name" = "dashboard-instance" }, local.amway_common_tags, local.amway_data_tags)
  }
}

resource "aws_autoscaling_group" "instance_asg" {
  name                = "dashboard-instance-asg"
  max_size            = "2"
  min_size            = 0
  desired_capacity    = 1
  vpc_zone_identifier = local.core_subnet_ids

  health_check_type         = "EC2"
  health_check_grace_period = 300

  target_group_arns = module.dashboard_alb.target_group_arns

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.instance_lt.id
        version            = "$Latest"
      }

      override {
        instance_type = "t3.medium"
      }

      override {
        instance_type = "t3.large"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      on_demand_allocation_strategy            = "prioritized"
      spot_allocation_strategy                 = "lowest-price"
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  tag {
    key                 = "Name"
    value               = "dashboard-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = merge(local.amway_common_tags, local.amway_ec2_tags)

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

}
