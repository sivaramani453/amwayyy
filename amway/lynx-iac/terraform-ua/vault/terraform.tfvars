# Environment
vault_cluster_name 		    = "vault-aweu"
vault_project_prefix		    = "AWEU"
# ALB
lb_dns_name                         = "vault-aweu.hybris.eia.amway.net"
lb_taget_group_port                 = "8200"
lb_taget_group_protocol             = "HTTP"
lb_taget_group_hc_protocol          = "HTTP"
lb_taget_group_hc_path              = "/v1/sys/health"
lb_taget_group_hc_response          = "200"
lb_allowed_ingress_cidrs            = ["10.0.0.0/8", "172.16.0.0/12"]
lb_listener_forward_certificate_arn = "arn:aws:acm:eu-central-1:860702706577:certificate/3bce1dc0-e691-4521-9fca-4f5430776282"
lb_ssl_policy			    = "ELBSecurityPolicy-TLS-1-2-2017-01"
# EC2
ec2_instance_type  		    = "t3.micro"
ec2_node_name      		    = "node"
vault_ssh_key_name 		    = "EPAM-SE"
root_volume_type   		    = "gp3"
root_volume_size   		    = "10"
aws_aweu_account   		    = "860702706577"
# S3
vault_s3_resources_bucket_name 	    = "vault-s3-resources-aweu"
vault_s3_data_bucket_name      	    = "vault-s3-data-aweu"
# DynamoDB
vault_dynamodb_table_name 	    = "vault-ha-coordination-aweu"
