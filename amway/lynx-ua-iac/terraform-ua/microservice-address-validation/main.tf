# module "ec2_zookeeper_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 2.16.0"

#   name           = "${terraform.workspace}-zookeeper-node"
#   instance_count = var.zookeeper_instance_count

#   ami                    = "ami-025eb2c2c5d794ee5"
#   ebs_optimized          = true
#   instance_type          = "t3.micro"
#   key_name               = "Jan Machalica"
#   monitoring             = true
#   vpc_security_group_ids = [module.zookeeper_ec2_sg.security_group_id]
#   subnet_ids             = data.terraform_remote_state.core-eks.outputs.infra_64_subnets

#   root_block_device = [
#     {
#       volume_type           = "gp2"
#       volume_size           = 20
#       delete_on_termination = true
#     },
#   ]

#   tags = merge(local.amway_common_tags, local.amway_ec2_specific_tags)
#   volume_tags = merge(
#     {
#       "ServiceType" = "zookeeper-node"
#     },
#     local.amway_common_tags,
#     local.amway_ebs_specific_tags,
#   )
# }

# module "ec2_solr_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 2.16.0"

#   name           = "${terraform.workspace}-solr-node"
#   instance_count = var.solr_instance_count

#   ami                    = "ami-0836addef744abb81"
#   ebs_optimized          = true
#   instance_type          = "t3.large"
#   key_name               = "Jan Machalica"
#   monitoring             = true
#   vpc_security_group_ids = [module.solr_ec2_sg.security_group_vpc_id]
#   subnet_ids             = data.terraform_remote_state.core-eks.outputs.infra_64_subnets

#   root_block_device = [
#     {
#       volume_type           = "gp3"
#       volume_size           = 50
#       delete_on_termination = true
#     },
#   ]

#   tags = merge(local.amway_common_tags, local.amway_ec2_specific_tags)
#   volume_tags = merge(
#     {
#       "ServiceType" = "solr-node"
#     },
#     local.amway_common_tags,
#     local.amway_ebs_specific_tags,
#   )
# }



# resource "null_resource" "provisioning_the_cluster" {
#   depends_on = [
#     aws_route53_record.zookeeper_node_urls,
#     aws_route53_record.solr_node_urls,
#     module.rds_pgsql,
#   ] # , "aws_route53_record.efs_urls"]

#   triggers = {
#     solr_instance_addr      = join(",", aws_route53_record.solr_node_urls[0].records)
#     zookeeper_instance_addr = join(",", aws_route53_record.zookeeper_node_urls[0].records)
#   }

#   provisioner "local-exec" {
#     on_failure = fail

#     command = <<EOT
#     echo "[solr]\n${join("\n", aws_route53_record.solr_node_urls.*.name)}\n[zookeeper]\n${join("\n", aws_route53_record.zookeeper_node_urls.*.name)}" > ./ansible/hosts;
#     ansible-galaxy install -r ./ansible/requirements.yml -p ./ansible/roles/ -f;
#     ansible-playbook ./ansible/bootstrap-cluster.yml -u centos -i ./ansible/hosts  --extra-vars "solr_efs_mountpoint_src='${aws_route53_record.efs_urls.name}' solr_additional_opts='-Djdbc.postgresql.host=${element(split(":", module.rds_pgsql.db_instance_endpoint), 0)} -Djdbc.postgresql.user=${var.microservice_db_user} -Djdbc.postgresql.pass=${var.microservice_db_pass} -Dadapter_auth_credentials=${var.adapter_auth_user}:${var.adapter_auth_pass} -Devent_sender_1_data=https://${var.address_validation_url}/api/v1/adapter/kz/solr_job_done -Devent_sender_2_data=https://${var.address_validation_url}/api/v1/adapter/ru/solr_job_done -Devent_sender_3_data=https://${var.address_validation_url}/api/v1/adapter/ua/solr_job_done'" --private-key="$PATH_TO_SSH_KEY";

# EOT


#     environment = {
#       ANSIBLE_SSH_RETRIES       = "5"
#       ANSIBLE_HOST_KEY_CHECKING = "False"
#       PATH_TO_SSH_KEY           = var.path_to_ssh_key
#     }
#   }
# }

