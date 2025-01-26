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
  default     = "frankfurt-eks-v3"
}

variable "vpc_id" {
  type        = string
  default     = "vpc-0db52c948cf518f3f"
}

variable "standard_workers_count" {
  type        = string
  description = "Number of standard worker instances"
  default     = "6"
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
  key_name   = "amway-microservices-production3"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDECSAO7vxuUDDliVacWX4bUuj0DDWOO27/VFbnSe5xDMwS1z1RY6nkwA/GMDTDcaBgZyhzvZ60mleHSgAsRgfcAyqaKSI4LA1bIjISAKsiMG7b2ZDNbsQpN/VqzVzZOFe6ZdKQa1YCyHBaQgWmI8/jKv8zMoi3smskAm85ta6LrpiXKwqrupcfcpr1EuLKG/VOSkqWTIG8cgqqKQ9pXMq9IV6Zrg5hdMmpcVuZaJcpIlgeIARgoOL97J+I8Ylw/MYI1ZrvQDGXME70df27ZeD+DsJUf0ZanRXpVPP3ui+sRJbs7LE8i7YKgFbzOEYvSAOY8m35vxpYu5NtqrKKRvTl8GQkxQZZnEn3AiknNRrEzGfBLhqPvqMTjVI8jkIjj68kck8GnU/JcJI0PnIp4jHLnaiJLnj/+lPVMYc+dEfJ2S1sKo1JachgYhk45b5EDjF/t4ld91Fu3zIUc4UVjL6c0mW31uBuHwd6tzHP567xRgQeBCU+5bztUlCnFWlLXrf76sHwCOxQKJW5lKjGo9g9rjncIKv0RfqCiv9iIujnZTT+/maHiZYruyjT3e94Xj6fo1pODHWhwzKIpOVVuDQeWC/VwBl8CANrOFILkeUQHXea33y28dtZklCyaA8j45++6M1pg3oICtCwfo3YxDo3tKRKHuZgmgvkNu1RqXdOaQ=="
}
