resource "aws_cloudwatch_log_group" "common" {
  name              = "${data.terraform_remote_state.core.project}-${var.service}"
  retention_in_days = "14"

  tags = "${local.tags}"
}

module "ecs-fargate" {
  source = "github.com/lean-delivery/tf-module-aws-ecs?ref=v0.2"

  project          = "${data.terraform_remote_state.core.project}"
  environment      = "${var.environment}"
  service          = "${var.service}"
  container_cpu    = "${var.cpu}"
  container_memory = "${var.memory}"
  vpc_id           = "${data.terraform_remote_state.core.vpc.dev.id}"

  subnets = [
    "${data.terraform_remote_state.core.subnet.core_a.id}",
    "${data.terraform_remote_state.core.subnet.core_b.id}",
  ]

  alb_target_group_arn  = "${module.alb.target_group_arns[0]}"
  container_port        = "${var.container_port}"
  container_definitions = "${data.template_file.container_definitions.rendered}"
  task_role_arn         = "${aws_iam_role.ecs-task-role.arn}"
}

# allow access from ALB to ECS
resource "aws_security_group_rule" "add_ingress_from_alb_security_group" {
  security_group_id = "${module.ecs-fargate.security_group_id}"
  type              = "ingress"

  source_security_group_id = "${module.alb_security_group.this_security_group_id}"
  description              = "Allow traffic from ALB"

  from_port = 0
  to_port   = 0
  protocol  = -1
}

# Allow access to S3 from ECS container
data "aws_iam_policy_document" "ecs-task-allow-s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs-task-allow-s3" {
  name        = "ecs-task-role-allow-s3-${var.service}-${var.environment}"
  description = "ECS task role policy to access s3"
  policy      = "${data.aws_iam_policy_document.ecs-task-allow-s3.json}"
}

resource "aws_iam_role" "ecs-task-role" {
  name = "ecs-task-role-${var.service}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = "${local.tags}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-s3" {
  role       = "${aws_iam_role.ecs-task-role.name}"
  policy_arn = "${aws_iam_policy.ecs-task-allow-s3.arn}"
}
