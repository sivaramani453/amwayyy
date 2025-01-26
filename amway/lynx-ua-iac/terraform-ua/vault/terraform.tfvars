# Environment
vault_cluster_name 		    = "vault-aweuua"
vault_project_prefix		    = "AWEUUA"
# ALB
lb_dns_name                         = "vault-ua.mspreprod.eia.amway.net"
lb_taget_group_port                 = "8200"
lb_taget_group_protocol             = "HTTP"
lb_taget_group_hc_protocol          = "HTTP"
lb_taget_group_hc_path              = "/v1/sys/health"
lb_taget_group_hc_response          = "200"
lb_allowed_ingress_cidrs            = ["10.0.0.0/8", "172.16.0.0/12"]
lb_listener_forward_certificate_arn = "arn:aws:acm:eu-central-1:728244295542:certificate/240f53e3-94fb-44ec-b30c-a356f49e5668"
lb_ssl_policy			    = "ELBSecurityPolicy-TLS-1-2-2017-01"
# EC2
ec2_instance_type  		    = "t3.micro"
ec2_node_name      		    = "node"
vault_ssh_key_name 		    = "AMWAY-UA"
root_volume_type   		    = "gp3"
root_volume_size   		    = "10"
aws_aweu_account   		    = "728244295542"
# S3
vault_s3_resources_bucket_name 	    = "vault-s3-resources-aweu-ua"
vault_s3_data_bucket_name      	    = "vault-s3-data-aweu-ua"
# DynamoDB
vault_dynamodb_table_name 	    = "vault-ha-coordination-aweu-ua"
# Route 53
dns_zone_id                         = "Z01421911PZSXATXW14QL"

