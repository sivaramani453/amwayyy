
module "bamboo_scale_agent_sg_es2" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.ecs_service_name}-ec2-service-sg"
  description = "Security group for the Bamboo scale agent ec2 instance"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 5900
      to_port     = 5910
      protocol    = "tcp"
      description = "Tiger VNC port"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    }
  ]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

module "bamboo_scale_agent_sg_ecs_service" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.ecs_service_name}-ecs-service-sg"
  description = "Security group for the Bamboo scale agent"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["http-80-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_log_group" "bamboo_scale_agent_cw_log" {
  name              = "${var.ecs_service_name}-log"
  retention_in_days = "14"

  tags = local.amway_common_tags
}

data "template_file" "ecs_container_difinition" {

  template = "${file("${path.module}/templates/container-definitions.json")}"
  vars = {
    name                               = lookup(local.container, "name")
    cpu                                = lookup(local.container, "cpu")
    memory_soft                        = lookup(local.container, "memory_soft")
    memory_hard                        = lookup(local.container, "memory_hard")
    port                               = lookup(local.container, "port")
    image_name                         = lookup(local.container, "image_name")
    region                             = data.aws_region.current.name
    log-group                          = aws_cloudwatch_log_group.bamboo_scale_agent_cw_log.name
    log-prefix                         = "amway"
    env_aws_ci_autotest_ami_id         = lookup(local.container, "aws_ci_autotest_ami_id")
    env_aws_ci_autotest_ami_snap_id    = lookup(local.container, "aws_ci_autotest_ami_snap_id")
    env_aws_ci_autotest_instance_shape = lookup(local.container, "aws_ci_autotest_instance_shape")
    env_aws_ci_autotest_disk_size      = lookup(local.container, "aws_ci_autotest_disk_size")
    env_aws_ci_autotest_spot_duration  = lookup(local.container, "aws_ci_autotest_spot_duration")
    env_aws_ci_ami_id                  = lookup(local.container, "aws_ci_ami_id")
    env_aws_ci_ami_snap_id             = lookup(local.container, "aws_ci_ami_snap_id")
    env_aws_ci_instance_shape          = lookup(local.container, "aws_ci_instance_shape")
    env_aws_ci_disk_size               = lookup(local.container, "aws_ci_disk_size")
    env_aws_ci_spot_duration           = lookup(local.container, "aws_ci_spot_duration")
    env_aws_ci_instance_kp             = lookup(local.container, "aws_ci_instance_kp")
    env_aws_ci_subnet_id_a             = element(local.ci_subnet_ids, 0)
    env_aws_ci_subnet_id_b             = element(local.ci_subnet_ids, 1)
    env_aws_ci_subnet_id_c             = element(local.ci_subnet_ids, 2)
    env_aws_ci_instance_profile        = aws_iam_instance_profile.bamboo_scale_agent_instance_iam_profile.name
    env_aws_ci_instance_sg             = module.bamboo_scale_agent_sg_es2.this_security_group_id
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_service_name

  tags = local.amway_common_tags
}

resource "aws_ecs_task_definition" "ecs_td" {

  family                   = "${var.ecs_service_name}-family"
  cpu                      = lookup(local.container, "cpu")
  memory                   = lookup(local.container, "memory_hard")
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = data.template_file.ecs_container_difinition.rendered
  task_role_arn         = module.bamboo_scale_agent_iam_role.this_iam_role_arn

  # this is predefined aws role
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"

  tags = local.amway_common_tags
}

resource "aws_ecs_service" "ecs_service" {

  name    = "${var.ecs_service_name}-service"
  cluster = aws_ecs_cluster.ecs_cluster.id

  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.ecs_td.arn
  desired_count   = lookup(local.container, "count")

  network_configuration {
    subnets         = local.core_subnet_ids
    security_groups = [module.bamboo_scale_agent_sg_ecs_service.this_security_group_id]
  }

  tags = local.amway_common_tags

}

resource "aws_cloudwatch_log_subscription_filter" "stream_to_elk" {
  depends_on = [aws_ecs_service.ecs_service]

  name            = "BambooScaleAgent-ecs-stream"
  filter_pattern  = "[timestamp, message]"
  log_group_name  = aws_cloudwatch_log_group.bamboo_scale_agent_cw_log.name
  destination_arn = data.aws_lambda_function.send_logs_to_elk.arn
}
