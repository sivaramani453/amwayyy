variable vpc_id {
  type        = string
  default     = "vpc-04d64ae6866c7d6d3"
  description = "AWS VPC ID for lambda"
}

variable subnet_id1 {
  type        = string
  default     = "subnet-086473b444bc5a220"
  description = "AWS VPC subnet1 ID for lambda"
}

variable subnet_id2 {
  type        = string
  default     = "subnet-0ee7713a9edfeb98b"
  description = "AWS VPC subnet2 ID for lambda"
}

variable git_token {
  type        = string
  default     = "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"
  description = "github personal access token"
}

variable git_org {
  type        = string
  default     = "sivaramani453"
  description = "github org name"
}

variable git_secret {
  type        = string
  default     = "zażółćgęśląjaźń"
  description = "secret of git to connect aws"
}

variable git_repo {
  type        = string
  default     = "gh-selfhosted"
  description = "github repo name"
}

variable teams_webhook_url {
  type        = string
  default     = "https://nagarro.webhook.office.com/webhookb2/ace09a4c-9e24-4cf3-8b0e-425a13642dc8@a45fe71a-f480-4e42-ad5e-aff33165aa35/IncomingWebhook/26b8bb1c1d514a6ca7e5ee3c799adfb1/6512d231-a894-4004-aa19-5805120e8906/V2MOiaZvARt1xvEUqQFUBvRLQx8PKb5cmAaP6ZzTeB7yM1"
  description = "teams url to notify"
}

variable spot_maxprice {
#   type        = string
  default     = "0.06"
  description = "max prce of spot instance"
}

variable instance_type {
  type        = string
  default     = "t3.small"
  description = "type of the instance"
}

variable instance_ondemand {
#   type        = string
  default     = "0"
  description = "description"
}

variable instance_ami {
  type        = string
  default     = "ami-0e2a989c802072f59"
  description = "AMI of the instance to launch as a github runner"
}

variable instance_disk_size {
#   type        = string
  default     = "10"
  description = "size of the ebs volume to attach instance"
}

variable instance_kp {
  type        = string
  default     = "github"
  description = "keypair of the instance"
}

variable instance_sg {
  type        = string
  default     = "sg-03040dbe268f59fa6"
  description = "security group of instance"
}

variable instance_subnet {
  type        = string
  default     = "subnet-0f02253d781e221c6"
  description = "subnet of instance"
}