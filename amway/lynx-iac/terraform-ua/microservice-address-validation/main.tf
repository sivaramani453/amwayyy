data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "core-eks" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "eks-v2/core.tfstate"
    region = "eu-central-1"
  }
}

module "ec2_zookeeper_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 1.0"

  name           = "${terraform.workspace}-zookeeper-node"
  instance_count = "${var.zookeeper_instance_count}"

  ami                    = "ami-0cf077499a07fcca4"
  ebs_optimized          = true
  instance_type          = "t3.micro"
  key_name               = "EPAM-SE"
  monitoring             = true
  vpc_security_group_ids = ["${module.zookeeper_ec2_sg.this_security_group_id}"]
  subnet_ids             = "${data.terraform_remote_state.core-eks.infra_64_subnets}"

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = 20
      delete_on_termination = true
    },
  ]

  tags        = "${merge(local.amway_common_tags, local.amway_ec2_specific_tags)}"
  volume_tags = "${merge(map("ServiceType", "zookeeper-node" ), local.amway_common_tags, local.amway_ebs_specific_tags)}"
}

module "ec2_solr_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 1.0"

  name           = "${terraform.workspace}-solr-node"
  instance_count = "${var.solr_instance_count}"

  ami                    = "ami-0cf077499a07fcca4"
  ebs_optimized          = true
  instance_type          = "t3.large"
  key_name               = "EPAM-SE"
  monitoring             = true
  vpc_security_group_ids = ["${module.solr_ec2_sg.this_security_group_id}"]
  subnet_ids             = "${data.terraform_remote_state.core-eks.infra_64_subnets}"

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = 50
      delete_on_termination = true
    },
  ]

  tags        = "${merge(local.amway_common_tags, local.amway_ec2_specific_tags)}"
  volume_tags = "${merge(map("ServiceType", "solr-node" ), local.amway_common_tags, local.amway_ebs_specific_tags)}"
}

module "rds_pgsql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier = "rds-${terraform.workspace}-e"

  engine                     = "postgres"
  engine_version             = "11.4"
  major_engine_version       = "11"
  instance_class             = "db.m5.large"
  allocated_storage          = 100
  max_allocated_storage      = 160
  storage_type               = "gp3"
  auto_minor_version_upgrade = false
  multi_az                   = false
  storage_encrypted          = true

  create_db_parameter_group = true
  create_db_subnet_group    = true
  family                    = "postgres11"

  username = "root"
  password = "${var.root_password}"
  port     = "5432"

  parameters = [
    {
      name  = "autovacuum_analyze_scale_factor"
      value = "0.1"
    },
    {
      name  = "autovacuum_vacuum_scale_factor"
      value = "0.2"
    },
    {
      name  = "autovacuum_naptime"
      value = "60"
    },
    {
      name  = "synchronous_commit"
      value = "off"
    },
    {
      name         = "shared_buffers"
      value        = "524288"
      apply_method = "pending-reboot"
    },
    {
      name         = "effective_cache_size"
      value        = "1572864"
      apply_method = "pending-reboot"
    },
    {
      name         = "maintenance_work_mem"
      value        = "1048576"
      apply_method = "pending-reboot"
    },
    {
      name  = "work_mem"
      value = "31457"
    },
    {
      name  = "random_page_cost"
      value = "1.1"
    },
    {
      name  = "effective_io_concurrency"
      value = "200"
    },
  ]

  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  apply_immediately                   = false
  iam_database_authentication_enabled = false
  deletion_protection                 = true

  maintenance_window      = "Mon:22:30-Mon:23:30"
  backup_window           = "00:30-01:30"
  backup_retention_period = 7

  vpc_security_group_ids = ["${module.pgsql_rds_sg.this_security_group_id}"]
  subnet_ids             = "${data.terraform_remote_state.core-eks.database_subnets}"

  tags = "${merge(local.amway_common_tags, local.amway_rds_specific_tags)}"
}

#resource "aws_efs_file_system" "efs_address_validation_fs" {
#  tags = "${merge(map("Name", "${terraform.workspace}-efs"), local.amway_common_tags, local.amway_efs_specific_tags)}"
#}

#resource "aws_efs_mount_target" "efs_address_validation_mt" {
#  count          = "${length(data.terraform_remote_state.core-eks.infra_64_subnets)}"
#  file_system_id = "${aws_efs_file_system.efs_address_validation_fs.id}"
#  subnet_id      = "${element(data.terraform_remote_state.core-eks.infra_64_subnets, count.index)}"

#  security_groups = [
#    "${module.efs_sg.this_security_group_id}",
#  ]
#}

#resource "aws_efs_access_point" "efs_address_validation_ap" {
#  file_system_id = "${aws_efs_file_system.efs_address_validation_fs.id}"

#  root_directory {
#    path = "/"
#  }

#  posix_user {
#    gid = 1001
#    uid = 997
#  }

#  tags = "${merge(map("Name", "${terraform.workspace}-efs"), local.amway_common_tags, local.amway_efs_specific_tags)}"
#}

resource "null_resource" "provisioning_the_cluster" {
  depends_on = ["aws_route53_record.zookeeper_node_urls", "aws_route53_record.solr_node_urls", "module.rds_pgsql"] # , "aws_route53_record.efs_urls"]
  
  triggers = {
    solr_instance_addr = "${join(",", aws_route53_record.solr_node_urls.*.records[0])}"
    zookeeper_instance_addr = "${join(",", aws_route53_record.zookeeper_node_urls.*.records[0])}"
  }

  provisioner "local-exec" {
    on_failure = "fail"

    command = <<EOT
    echo "[solr]\n${join("\n", aws_route53_record.solr_node_urls.*.name)}\n[zookeeper]\n${join("\n", aws_route53_record.zookeeper_node_urls.*.name)}" > ./ansible/hosts;
    ansible-galaxy install -r ./ansible/requirements.yml -p ./ansible/roles/ -f;
    ansible-playbook ./ansible/bootstrap-cluster.yml -u centos -i ./ansible/hosts  --extra-vars "solr_efs_mountpoint_src='${aws_route53_record.efs_urls.name}' solr_additional_opts='-Djdbc.postgresql.host=${element(split(":", module.rds_pgsql.this_db_instance_endpoint),0)} -Djdbc.postgresql.user=${var.microservice_db_user} -Djdbc.postgresql.pass=${var.microservice_db_pass} -Dadapter_auth_credentials=${var.adapter_auth_user}:${var.adapter_auth_pass} -Devent_sender_1_data=https://${var.address_validation_url}/api/v1/adapter/kz/solr_job_done -Devent_sender_2_data=https://${var.address_validation_url}/api/v1/adapter/ru/solr_job_done -Devent_sender_3_data=https://${var.address_validation_url}/api/v1/adapter/ua/solr_job_done'" --private-key="$PATH_TO_SSH_KEY";
  EOT

    environment = {
      ANSIBLE_SSH_RETRIES       = "5"
      ANSIBLE_HOST_KEY_CHECKING = "False"
      PATH_TO_SSH_KEY           = "${var.path_to_ssh_key}"
    }
  }
}
