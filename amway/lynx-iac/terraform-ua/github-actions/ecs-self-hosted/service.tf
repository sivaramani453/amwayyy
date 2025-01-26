data "template_file" "container-difinition" {
  count    = "${length(local.services)}"
  template = "${file("${path.module}/templates/container-definitions.json")}"

  vars {
    git_org            = "${lookup(local.services[count.index], "git_org")}"
    git_repo           = "${lookup(local.services[count.index], "git_repo")}"
    git_token          = "${lookup(local.services[count.index], "git_token")}"
    labels             = "${lookup(local.services[count.index], "labels")}"
    init_image         = "${lookup(local.services[count.index], "init_image")}"
    runner_image       = "${lookup(local.services[count.index], "runner_image")}"
    runner_memory_soft = "${lookup(local.services[count.index], "runner_memory_soft")}"
    runner_memory_hard = "${lookup(local.services[count.index], "runner_memory_hard")}"
    sonar_url          = "${lookup(local.services[count.index], "sonar_url", "")}"
    dm_az              = "${lookup(local.services[count.index], "dm_az", "")}"
    dm_region          = "${lookup(local.services[count.index], "dm_region", "")}"
    dm_vpc_id          = "${lookup(local.services[count.index], "dm_vpc_id", "")}"
    dm_subnet_id       = "${lookup(local.services[count.index], "dm_subnet_id", "")}"
    dm_is_spot         = "${lookup(local.services[count.index], "dm_is_spot", "")}"
    dm_block_duration  = "${lookup(local.services[count.index], "dm_block_duration", "")}"
    dm_instance_type   = "${lookup(local.services[count.index], "dm_instance_type", "")}"
    dm_security_group  = "${aws_security_group.sg.name}"
  }
}

resource "aws_ecs_task_definition" "ga-td" {
  count                 = "${length(local.services)}"
  family                = "${lower(lookup(local.services[count.index], "git_org"))}-${lower(lookup(local.services[count.index], "git_repo"))}"
  container_definitions = "${element(data.template_file.container-difinition.*.rendered, count.index)}"

  task_role_arn = "${aws_iam_role.ecs-ga-role.arn}"

  # this is predefined aws role
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
}

resource "aws_ecs_service" "ecs-service" {
  count   = "${length(local.services)}"
#  name    = "${count.index}-${lower(lookup(local.services[count.index], "git_org"))}-${lower(lookup(local.services[count.index], "git_repo"))}"
  name    = "${lower(lookup(local.services[count.index], "git_org"))}-${lower(lookup(local.services[count.index], "git_repo"))}-service"
  cluster = "${var.cluster_name}"

  task_definition = "${element(aws_ecs_task_definition.ga-td.*.family, count.index)}:${element(aws_ecs_task_definition.ga-td.*.revision, count.index)}"
  desired_count   = "${lookup(local.services[count.index], "runners")}"
}
