variable "project" {
  description = "Project name is used to identify resources"
  type        = string
}

variable "environment" {
  description = "Environment name is used to identify resources"
  type        = string
}

variable "root_domain" {
  description = "Root domain in which custom DNS record for ALB would be created"
}

variable "external_dns_policy" {
  description = "Policy for external DNS, available options are: sync, upsert-only"
  default     = "sync"
}

variable "local_exec_interpreter" {
  description = "Command to run for local-exec resources. Must be a shell-style interpreter. If you are on Windows Git Bash is a good choice."
  type        = list
  default     = ["/bin/sh", "-c"]
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.14"
}

variable "cluster_enabled_log_types" {
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = list
  default     = []
}

variable "map_accounts_count" {
  description = "The count of accounts in the map_accounts list."
  type        = string
  default     = 0
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = list
  default     = []
}

variable "map_roles_count" {
  description = "The count of roles in the map_roles list."
  type        = string
  default     = 0
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = list
  default     = []
}

variable "map_users_count" {
  description = "The count of roles in the map_users list."
  type        = string
  default     = 0
}

variable "vpc_id" {
  description = "VPC ID for cluster provisioning"
  type        = string
}

variable "spot_subnets" {
  description = "List of private subnets for cluster worker nodes provisioning"
  type        = list
}

variable "additional_spot_subnets" {
  description = "List of private subnets for cluster worker nodes provisioning"
  type        = list
}

variable "public_subnets" {
  description = "List of public subnets for ALB provisioning"
  type        = list
}

variable "additional_sg_id" {
  description = "Additional sg to attach to every node"
  type        = string
}

variable "target_group_arns" {
  description = "Predefined target groups to attch to asgs"
  type        = list
}

#########################WORKER_NODES#########################
variable "volume_size" {
  description = "Volume size(GB) for worker node in cluster"
  type        = string
  default     = "100"
}

variable "ondemand_volume_size" {
  description = "Volume size(GB) for ondemand worker node in cluster"
  type        = string
  default     = "200"
}

variable "worker_nodes_ssh_key" {
  description = "If Public ssh key provided, will be used for ssh access to worker nodes. Otherwise instances will be created without ssh key."
  type        = string
  default     = ""
}

variable "spot_configuration" {
  description = "List of maps that contains configurations for ASGs with spot workers instances what will be used in EKS-cluster"
  type        = list

  default = [
    {
      instance_type              = "m4.large"
      additional_instance_type_1 = "t3.large"
      additional_instance_type_2 = "m5.large"
      spot_price                 = "0.05"
      asg_max_size               = "4"
      asg_min_size               = "1"
      asg_desired_capacity       = "1"
      additional_kubelet_args    = ""
    },
    {
      instance_type              = "m4.xlarge"
      additional_instance_type_1 = "t3.xlarge"
      additional_instance_type_2 = "m5.xlarge"
      spot_price                 = "0.08"
      asg_max_size               = "4"
      asg_min_size               = "0"
      asg_desired_capacity       = "0"
      additional_kubelet_args    = ""
    },
  ]
}

variable "on_demand_configuration" {
  description = "List of maps that contains configurations for ASGs with on-demand workers instances what will be used in EKS-cluster"
  type        = list

  default = [
    {
      instance_type           = "m4.xlarge"
      asg_max_size            = "6"
      asg_min_size            = "0"
      asg_desired_capacity    = "0"
      additional_kubelet_args = ""
    },
  ]
}

variable "service_on_demand_configuration" {
  description = "List of maps that contains configurations for ASGs with on-demand workers instances what will be used in EKS-cluster"
  type        = list

  default = [
    {
      instance_type           = "t3.small"
      asg_max_size            = "1"
      asg_min_size            = "1"
      asg_desired_capacity    = "1"
      additional_kubelet_args = ""
    },
  ]
}

#########################DEPLOYMENTS FOR EKS CLUSTER#########################

variable "deploy_external_dns" {
  description = "Set true for External DNS installation (https://github.com/kubernetes-incubator/external-dns#externaldns)"
  type        = string
  default     = "false"
}

