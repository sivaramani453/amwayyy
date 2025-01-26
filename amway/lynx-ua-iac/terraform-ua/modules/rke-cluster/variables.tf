variable "region" {
}

# Nodes config
variable "ami" {
  description = "ami to create master and worker nodes"
}

variable "masters" {
  description = "Number of master nodes. Must be more then 0, odd"
  default     = 1
}

variable "workers" {
  description = "Number of worker nodes. Must be more then 1."
  default     = 1
}

variable "master_shape" {
  description = "instance type for master"
  default     = "t3.large"
}

variable "master_volume_size" {
  description = "rootfs volume size for master nodes"
  default     = "25"
}

variable "worker_shape" {
  description = "instance type for worker nodes"
  default     = "t3.large"
}

variable "worker_volume_size" {
  description = "rootfs volume size for worker nodes"
  default     = "25"
}

variable "key_pair" {
  description = "key pair name"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
}

variable "tags" {
  type = map(string)

  default = {
    Terraform = "true"
    Engine    = "rke"
  }
}

# Network config
variable "vpc_id" {
  description = "vpc id to place kubernetes cluster"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets to place nodes and load balancer endpoints"
}

variable "allow_ssh_from_subnets" {
  description = "List of subnets to allow ssh access from"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12"]
}

variable "allow_kube_api_subnets" {
  type        = list(string)
  description = "List of subnets to allow access to kubertnetes API server (kubectl for instance)"
  default     = ["10.0.0.0/8", "172.16.0.0/12"]
}

variable "allow_node_ports_subnets" {
  type        = list(string)
  description = "List of subnets to allow access to kubernetes node port services"
  default     = ["10.0.0.0/8", "172.16.0.0/12"]
}

variable "allow_nginx_ingress_ports_subnets" {
  type        = list(string)
  description = "List of subnets to allow access to ingress nginx"
  default     = ["10.0.0.0/8", "172.16.0.0/12"]
}

variable "create_route53" {
  description = "Do you want to create route53 alias to kube api nlb"
  default     = false
}

variable "route53_zone_id" {
  description = "Route 53 zone id to add domain name: {cluster_name}.{zone_name}"
  default     = ""
}

variable "route53_zone_name" {
  description = "Route 53 zone name to add domain name: {cluster_name}.{zone_name}"
  default     = ""
}

variable "s3_stage" {
  description = "s3 bucket name stage prefix"
  default     = "dev"
}

