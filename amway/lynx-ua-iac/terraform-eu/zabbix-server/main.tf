data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "zabbix_server_ami" {
  owners      = ["self", "amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["zabbix-server*"]
  }
}

resource "aws_iam_instance_profile" "zabbix_server_iam_profile" {
  name = "${terraform.workspace}-iam-profile"
  role = module.zabbix_server_iam_role.this_iam_role_name
}

module "zabbix_server_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "${terraform.workspace}-iam-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.zabbix_server_clw_access_policy.arn,
  ]
  number_of_custom_role_policy_arns = 1

  tags = local.amway_common_tags
}

module "zabbix_server_clw_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "ZabbixCLWAccess-${terraform.workspace}"
  path        = "/"
  description = "Policy for zabbix server to access the cloudwatch metrics"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF
}


module "zabbix_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "${terraform.workspace}"
  instance_count = length(local.core_subnet_ids)

  ami                         = data.aws_ami.zabbix_server_ami.id
  instance_type               = "t3.large"
  key_name                    = data.terraform_remote_state.core.outputs.frankfurt_ssh_key
  vpc_security_group_ids      = [module.zabbix_server_sg.this_security_group_id]
  subnet_ids                  = local.core_subnet_ids
  iam_instance_profile        = aws_iam_instance_profile.zabbix_server_iam_profile.name
  associate_public_ip_address = false
  source_dest_check           = true
  ebs_optimized               = true
  monitoring                  = false

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "100"
      delete_on_termination = true
    },
  ]

  tags        = merge(local.amway_common_tags, local.amway_ec2_tags)
  volume_tags = merge(local.amway_common_tags, local.amway_data_tags)
}

module "zabbix_server_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${terraform.workspace}-sg"
  description = "Allow access to the zabbix server communication ports"
  vpc_id      = data.terraform_remote_state.core.outputs.frankfurt_dev_vpc_id

  ingress_cidr_blocks = local.vpn_subnet_cidrs
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 10050
      to_port     = 10052
      protocol    = "tcp"
      description = "Zabbix server communication ports"
      cidr_blocks = join(",", local.vpn_subnet_cidrs)
    },
  ]

  egress_rules = ["all-all"]

  tags = local.amway_common_tags
}

resource "aws_route53_record" "zabbix_server" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "zabbix.${local.route53_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [join(",", module.zabbix_server.private_ip)]
}
