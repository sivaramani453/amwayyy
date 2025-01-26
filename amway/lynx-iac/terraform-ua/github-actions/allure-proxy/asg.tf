resource "aws_launch_template" "allure-lt" {
  name_prefix = "ga-allure-proxy"

  image_id      = "${data.aws_ami.allure-ami.id}"
  instance_type = "t3.micro"

  vpc_security_group_ids = ["${module.instance_security_group.this_security_group_id}"]
  key_name               = "${var.key_pair_name}"
  ebs_optimized          = true
  user_data              = "${base64encode(data.template_file.userdata.rendered)}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = "${var.disk_size}"
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs-asg" {
  name                = "allure-proxy-asg"
  max_size            = "2"
  min_size            = 0
  desired_capacity    = 1
  vpc_zone_identifier = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]

  health_check_type         = "EC2"
  health_check_grace_period = 300

  target_group_arns = ["${aws_lb_target_group.asg_tg.arn}"]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.allure-lt.id}"
        version            = "$Latest"
      }

      override {
        instance_type = "t3.small"
      }

      override {
        instance_type = "t3.medium"
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
    ignore_changes        = ["desired_capacity"]
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Schedule"
    value               = "running"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "allure-proxy-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "ApplicationID"
    value               = "${var.app_id}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.app_env}"
    propagate_at_launch = true
  }
}
