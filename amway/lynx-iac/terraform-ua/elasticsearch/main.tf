provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.7.0"
}

locals {
  tags = "${map(
    "Service", "elasticsearch",
    "Environment", "${var.environment}",
    "Terraform", "true"
  )}"
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_iam_service_linked_role" "elasticsearch" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_security_group" "elasticsearch" {
  name        = "epam-es-${var.domain}"
  description = "Managed by Terraform"
  vpc_id      = "${data.terraform_remote_state.core.vpc.dev.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${data.terraform_remote_state.core.vpc.dev.cidr_block}",
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/22",
    ]
  }

  tags = "${local.tags}"
}

resource "aws_cloudwatch_log_group" "elasticsearch" {
  name              = "${var.domain}"
  retention_in_days = 7

  tags = "${local.tags}"
}

resource "aws_cloudwatch_log_resource_policy" "elasticsearch" {
  policy_name = "${var.domain}-cw-policy"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_elasticsearch_domain" "epam-elasticsearch" {
  domain_name           = "aws-elasticsearch"
  elasticsearch_version = "6.7"

  vpc_options {
    subnet_ids = [
      "${data.terraform_remote_state.core.subnet.core_a.id}",
    ]

    security_group_ids = ["${aws_security_group.elasticsearch.id}"]
  }

  cluster_config {
    instance_type            = "r5.large.elasticsearch"
    instance_count           = 2
    dedicated_master_enabled = false
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = 200
  }

  snapshot_options {
    automated_snapshot_start_hour = 0
  }

  log_publishing_options {
    enabled                  = true
    log_type                 = "ES_APPLICATION_LOGS"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.elasticsearch.arn}"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  tags = "${local.tags}"

  depends_on = [
    "aws_iam_service_linked_role.elasticsearch",
  ]
}
