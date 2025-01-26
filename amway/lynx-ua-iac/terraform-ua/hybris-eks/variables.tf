variable "region" {
  type        = string
  default     = "eu-central-1"
}

variable "cluster-exist" {
  type        = number
  description = "Is cluster already created 1/0"
  default     = 1
}


variable "cluster_name" {
  type        = string
  description = "Number of standard worker instances"
  default     = "hybris-eks"
}

variable "vpc_id" {
  type        = string
#  default     = "vpc-0db52c948cf518f3f"
  default     = "vpc-1fbfbe76"
}

variable "standard_workers_count" {
  type        = string
  description = "Number of standard worker instances"
  default     = "2"
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
      rolearn  = "arn:aws:iam::860702706577:role/AWS-CDA-860702706577-OWNER"
      username = "accountowner"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::860702706577:role/AWS-CDA-860702706577-CONTRIB"
      username = "accountcontrib"
      groups   = ["system:masters"]
    },
  ]
}

resource "aws_key_pair" "amway-microservices-dev" {
  key_name   = "amway-ansible-deployment"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzX3UBP+PcRwT+KtM3jxlAPrsihEaFaKN74SafmeL0WwCCIk0doHihXc4/bW3Np1VgV8b9Jlr63g7eIFlzdlG3KxqFXFbG+TF/oNjmdmConzQ0uj7l75+xBEBYfN//ZEx5H9V5Am1G/gd/dCGUVV7lyae2CqipNwHsPcfweQixg5huh1cn8511fpYDKSRdVI+qF3flBo6lwNALQI23+TJ8mGHW/Hj3iw1FWD3JqK/gKr1Wvrit1v7gCDQ8wNDVRp/3FElCrH+DQlXgs74x7z6NeZbGUvCfLwOuDFVWOFQr2mvBDpNuCVEB188bHWW2dj9dzv3YCFIGxoPP2dUUIFur"
}
