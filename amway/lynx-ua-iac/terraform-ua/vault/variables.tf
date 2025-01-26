### EC2
variable "ec2_instance_type" {
  type        = "string"
  description = "The type of instance to launch vault on"
  default     = "t3.micro"
}

variable "ec2_node_name" {
  type        = "string"
  description = "Vault node name"
  default     = "vault-node"
}

variable "ec2_instance_count" {
  default = "2"
}

variable "vault_ssh_key_name" {
  type        = "string"
  description = "The name of the ssh key to use for the EC2 instance"
}

variable "aws_aweu_account" {
  default = "728244295542"
}

variable "vault_cluster_name" {
  type        = "string"
  description = "Vault cluster name"
}

variable "vault_project_prefix" {
  type        = "string"
  description = "Vault project prefix to use in conjunction with other variables"
}

variable "region" {
  type        = "string"
  description = "The AWS region to use"
  default     = "eu-central-1"
}

### Load Balancer

variable "lb_dns_name" {
  type        = "string"
  description = "The DNS of load balancer that vault will be accessible at"
  default     = "vault-ua.mspreprod.eia.amway.net"
}

variable "lb_taget_group_port" {
  description = "Port on target machine where all requests are being redirected from load balancer"
  default     = 8200
}

variable "lb_taget_group_protocol" {
  description = "Protocol on target machine where all requests are being redirected from load balancer"
  default     = "HTTP"
}

variable "lb_taget_group_hc_protocol" {
  description = "Health check protocol"
  default     = "HTTP"
}

variable "lb_taget_group_hc_path" {
  description = "Health check path"
  default     = "/v1/sys/health"
}

variable "lb_taget_group_hc_response" {
  description = "Expected health check response"
  default     = 200
}

variable "lb_taget_group_interval" {
  description = "Heath check interval"
  default     = "5"
}

variable "lb_taget_group_timeout" {
  description = "Heath check timeout"
  default     = "3"
}

variable "lb_taget_group_healthy_threshold" {
  description = "Heath check: healthy threshold"
  default     = "2"
}

variable "lb_taget_group_unhealthy_threshold" {
  description = "Heath check: unhealthy threshold"
  default     = "2"
}

variable "lb_allowed_ingress_cidrs" {
  type        = "list"
  description = "A list of CIDRs to allow traffic into the ALB"
  default     = []
}

variable "lb_listener_forward_certificate_arn" {
  type        = "string"
  description = "The ARN of the certificate to use on the ALB"
  default     = "arn:aws:acm:eu-central-1:728244295542:certificate/240f53e3-94fb-44ec-b30c-a356f49e5668"
}

variable "lb_ssl_policy" {
  type        = "string"
  description = "A Security policies for ALB"
  default     = ""
}

### Volumes

variable "root_volume_type" {
  description = "Root volume type"
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root volume size"
  default     = 10
}

### S3

variable "vault_s3_resources_bucket_name" {
  type        = "string"
  description = "The name of the vault resources bucket"
}

variable "vault_s3_data_bucket_name" {
  type        = "string"
  description = "The name of the vault data bucket"
}

### DynamoDB

variable "vault_dynamodb_table_name" {
  type        = "string"
  description = "The name of the dynamodb table that vault will create to coordinate HA"
}

### Custom tags for different sources

variable "custom_tags_common" {
  description = "Amway custom tags"
  type        = "map"

  default = {
    Terraform     = "true"
    ApplicationID = "APP3151110"
    Environment   = "dev"
  }
}

variable "custom_tags_instance" {
  description = "Amway instance tags"
  type        = "map"

  default = {
    DataClassification = "internal"
    SEC-INFRA-13       = "Appliance"
    SEC-INFRA-14       = "Null"
  }
}

variable "custom_tags_spec" {
  description = "Amway custom tags"
  type        = "map"

  default = {
    DataClassification = "internal"
  }
}
### Route53

variable "dns_zone_id" {
  type        = "string"
  description = "The dns zoneid of hosted zone in route53"
}

