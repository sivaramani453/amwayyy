module "instance_scheduler_sg_ecs_service" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.ecs_service_name}-ecs-service-sg"
  description = "Security group for the AWS Instance Scheduler to Allow traffic from ALB"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_log_group" "instance_scheduler_cw_log" {
  name              = "${var.ecs_service_name}-log"
  retention_in_days = "14"

  tags = local.amway_common_tags
}


data "template_file" "ecs_container_difinition" {

  template = "${file("${path.module}/templates/container-definitions.json")}"
  vars = {
    name                    = lookup(local.container, "name")
    cpu                     = lookup(local.container, "cpu")
    memory_soft             = lookup(local.container, "memory_soft")
    memory_hard             = lookup(local.container, "memory_hard")
    port                    = lookup(local.container, "port")
    image_name              = lookup(local.container, "image_name")
    region                  = data.aws_region.current.name
    log-group               = aws_cloudwatch_log_group.instance_scheduler_cw_log.name
    log-prefix              = "amway"
    env_tb_users            = module.instance_scheduler_dynamodb_users_table.this_dynamodb_table_id
    env_tb_groups           = module.instance_scheduler_dynamodb_groups_table.this_dynamodb_table_id
    env_tb_default_schedule = module.instance_scheduler_dynamodb_default_schedule_table.this_dynamodb_table_id
    env_tb_config           = var.instance_scheduler_config_table_name
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
  task_role_arn         = module.instance_scheduler_iam_role.this_iam_role_arn

  # this is predefined aws role
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
}

resource "aws_ecs_service" "ecs_service" {

  name    = "${var.ecs_service_name}-service"
  cluster = aws_ecs_cluster.ecs_cluster.id

  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.ecs_td.arn
  desired_count   = lookup(local.container, "count")

  network_configuration {
    subnets         = local.core_subnet_ids
    security_groups = [module.instance_scheduler_sg_ecs_service.this_security_group_id]
  }

  load_balancer {
    target_group_arn = module.instance_scheduler_lb.target_group_arns[0]
    container_name   = lookup(local.container, "name")
    container_port   = lookup(local.container, "port")
  }

  tags = local.amway_common_tags

}
