default_tags = {
  ApplicationID = "APP3001240",
  Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
  Project       = "CICD",
  Country       = "Japan",
  Environment   = "PROD"
}

eks_cluster_config = {
  name    = "jpn-automation"
  version = "1.29"
  vpc_id  = "vpc-00dccfbae7576eec2"
  subnet_ids = [
    "subnet-00e7c840fd4c76623",
    "subnet-077e527628ddac6c7"
  ]
  security_group_ids      = []
  policy_arns             = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
  automation_account_root = "arn:aws:iam::074806990885:root"
  eks_auth_roles = [{
    rolearn  = "arn:aws:iam::074806990885:role/AWS-CDA-074806990885-OWNER"
    username = "admin"
    groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::074806990885:role/jpn-prod-infra-deployment"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
}

node_groups = {
  spot = {
    use_name_prefix                 = true
    launch_template_use_name_prefix = true
    description                     = "On-demand instances"
    name                            = "jpn-automation-ondemand"
    iam_role_name                   = "jpn-automation-ondemand"
    instance_types                  = ["t3.large", "t2.large"]
    capacity_type                   = "ON_DEMAND"
    subnet_ids = [
      "subnet-00e7c840fd4c76623",
      "subnet-077e527628ddac6c7"
    ]
    min_size     = 1
    max_size     = 4
    desired_size = 2

    launch_template_tags = {
      ApplicationID = "APP3001240",
      Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
      Project       = "CICD",
      Country       = "Japan",
      Environment   = "PROD"
    }
  }
}

domain_info = {
  domain_name               = "automation.jp.amway.net"
  subject_alternative_names = ["*.automation.jp.amway.net"]
  route53_zone              = "automation.jp.amway.net"
  txtOwnerId                = "Z0592833MJPUT1JK9DA4"
}

github_config_url = "https://github.com/AmwayCommon"
