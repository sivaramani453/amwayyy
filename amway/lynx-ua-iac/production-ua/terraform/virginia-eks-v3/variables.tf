variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "cluster-exist" {
  type        = number
  description = "Is cluster already created 1/0"
  default     = 1
}

variable "cluster_name" {
  type        = string
  description = "Number of standard worker instances"
  default     = "virginia-eks-v3"
}

variable "vpc_id" {
  type        = string
  default     = "vpc-04dd737a925a4ff4d"
}

variable "standard_workers_count" {
  type        = string
  description = "Number of standard worker instances"
  default     = "3"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::645993801158:role/AWS-CDA-645993801158-OWNER"
      username = "accountowner"
      groups   = ["system:masters"]
    },
  ]
}

resource "aws_key_pair" "amway-microservices-production" {
  key_name   = "amway-microservices-production3"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq6LDAcJZ5F1/ErM4OowluzmQJdWMW/9RuYQnrj+/dferFeNegGthKD6oI8oBy1TIx8WPf++R7xy8O4tzTxBS8V4zprujfydEgG0btdR2rr1MhqHsfmoJOK/1K5HJqDfGNcWY+N2oNK84njMgRVMSIWWjTfF6R0BLObuvCIRRiJLh3ItVmZGiYa0At0bjxShlRb9eldOGTa5OogJoE1ygfxTMjnccdr7gw+S+BFQl4zCSAQohgwep11wSLn/SawsWRhz1bLzPRVkU7JuR6d6CqgGpoOUOn4AMiT9Bq/RhxtRSS5BtOKF4NyVDSe1BoT1ElqHubR6Y/J71KB2WLKFSv root@CentOS7x64"
}
