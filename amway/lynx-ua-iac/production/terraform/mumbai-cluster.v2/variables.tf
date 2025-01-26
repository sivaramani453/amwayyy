variable "cluster_name" {
  default = "mumbai-cluster-v2"
}

variable "master_count" {
  description = "Number of master nodes"
  default     = 5
}

variable "worker_count" {
  description = "Number of worker nodes"
  default     = 3
}

# As we now cant create users in account we have to use existing one to
# attach s3 policy
variable "rke_aws_user" {
  default = "amway-prod-mumbaiclusterrkeconfig"
}
