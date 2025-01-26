data "aws_region" "current" {}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_cloudwatch_log_group" "elasticsearch" {
  name              = terraform.workspace
  retention_in_days = 7

  tags = local.amway_common_tags
}

resource "aws_cloudwatch_log_resource_policy" "elasticsearch" {
  policy_name = "${terraform.workspace}-cw-policy"

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

resource "aws_iam_service_linked_role" "elasticsearch" {
  aws_service_name = "es.amazonaws.com"
  description      = "AWSServiceRoleForAmazonElasticsearchService Service-Linked Role"
}

resource "aws_elasticsearch_domain_policy" "elasticsearch_cluster" {
  domain_name = aws_elasticsearch_domain.elasticsearch_cluster.domain_name

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
              "AWS": "*"
             },
            "Action": "es:*",
            "Resource": "${aws_elasticsearch_domain.elasticsearch_cluster.arn}/*"
        }
    ]
}
POLICIES
}

resource "aws_route53_record" "custom_endpoint" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "elasticsearch.${local.route53_zone_name}"
  ttl     = "60"
  type    = "CNAME"

  records = [aws_elasticsearch_domain.elasticsearch_cluster.endpoint]
}

module "elasticsearch_cluster_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${terraform.workspace}-sg"
  description = "Allow traffic traffic into the elasticsearch cluster"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_elasticsearch_domain" "elasticsearch_cluster" {
  domain_name           = terraform.workspace
  elasticsearch_version = "6.8"

  vpc_options {
    subnet_ids = local.core_subnet_ids

    security_group_ids = [module.elasticsearch_cluster_sg.this_security_group_id]
  }

  cluster_config {
    instance_type            = "r5.large.elasticsearch"
    instance_count           = length(local.core_subnet_ids)
    dedicated_master_enabled = false
    zone_awareness_enabled   = true

    zone_awareness_config {
      availability_zone_count = length(local.core_subnet_ids)
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 200
  }

  snapshot_options {
    automated_snapshot_start_hour = 0
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  log_publishing_options {
    enabled                  = true
    log_type                 = "ES_APPLICATION_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch.arn
  }

  tags = merge(local.amway_common_tags, local.amway_data_tags, { Name = terraform.workspace })

  depends_on = [aws_iam_service_linked_role.elasticsearch]
}
