module "ecs-fargate" {
  source = "github.com/lean-delivery/tf-module-aws-ecs?ref=v0.6"

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
  container_definitions = "${data.template_file.container_definitions.rendered}"
  task_role_arn         = "${aws_iam_role.ecs-task-role.arn}"

  # Disable alb with setting grace period as maximum
  health_check_grace_period_seconds = "2147483647"
  container_port                    = "80"
}

# Create role 
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

# Allow access to ec2 from ECS container
data "aws_iam_policy_document" "ecs-task-allow-ec2" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs-task-allow-ec2" {
  name        = "ecs-task-role-allow-ec2-${var.service}-${var.environment}"
  description = "ECS task role policy to access ec2"
  policy      = "${data.aws_iam_policy_document.ecs-task-allow-ec2.json}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-ec2" {
  role       = "${aws_iam_role.ecs-task-role.name}"
  policy_arn = "${aws_iam_policy.ecs-task-allow-ec2.arn}"
}

# Allow access to ssm from ECS container
data "aws_iam_policy_document" "ecs-task-allow-ssm" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs-task-allow-ssm" {
  name        = "ecs-task-role-allow-ssm-${var.service}-${var.environment}"
  description = "ECS task role policy to access ssm"
  policy      = "${data.aws_iam_policy_document.ecs-task-allow-ssm.json}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-ssm" {
  role       = "${aws_iam_role.ecs-task-role.name}"
  policy_arn = "${aws_iam_policy.ecs-task-allow-ssm.arn}"
}

# Allow access to ECR from ECS container
data "aws_iam_policy_document" "ecs-task-allow-ecr" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = [
      "arn:aws:ecr:eu-central-1:860702706577:repository/scale_agents",
    ]
  }
}

resource "aws_iam_policy" "ecs-task-allow-ecr" {
  name        = "ecs-task-role-allow-ecr-${var.service}-${var.environment}"
  description = "ECS task role policy to access ecr"
  policy      = "${data.aws_iam_policy_document.ecs-task-allow-ecr.json}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-ecr" {
  role       = "${aws_iam_role.ecs-task-role.name}"
  policy_arn = "${aws_iam_policy.ecs-task-allow-ecr.arn}"
}
