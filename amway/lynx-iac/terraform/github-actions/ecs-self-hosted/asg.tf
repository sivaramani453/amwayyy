resource "aws_launch_template" "ecs-lt" {
  name_prefix   = "${var.cluster_name}"
  image_id      = "${data.aws_ami.ecs-ami.id}"
  instance_type = "${var.instance_type}"

  iam_instance_profile {
    name = "${aws_iam_instance_profile.ecs-instance-profile.id}"
  }

  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  key_name               = "${var.key_pair_name}"
  ebs_optimized          = true

  user_data = "${base64encode(data.template_file.userdata.rendered)}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = "${var.volume_size}"
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs-asg" {
  name                = "${var.cluster_name}-asg"
  max_size            = "${var.cluster_max_size}"
  min_size            = 0
  desired_capacity    = 2
  vpc_zone_identifier = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}"]

  health_check_type         = "EC2"
  health_check_grace_period = 300

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.ecs-lt.id}"
        version            = "$Latest"
      }

      override {
        instance_type = "${var.additional_instance_type_1}"
      }

      override {
        instance_type = "${var.additional_instance_type_2}"
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

  #@TODO: Tagging

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
    value               = "ga-dev-node"
    propagate_at_launch = true
  }
}
