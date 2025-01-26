default_tags = {
  ApplicationID = "APP3001241",
  Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
  Project       = "CICD",
  Country       = "Japan",
  Environment   = "DEV"
}

eks_cluster_config = {
  name    = "jpn-automation"
  version = "1.29"
  vpc_id  = "vpc-0d1aa036eb0120566"
  subnet_ids = [
    "subnet-06b6f68878d1c52aa",
    "subnet-0ea3a984379b2eedf"
  ]
  security_group_ids      = []
  policy_arns             = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
  automation_account_root = "arn:aws:iam::492449516969:root"
  eks_auth_roles = [{
    rolearn  = "arn:aws:iam::492449516969:role/AWS-CDA-492449516969-OWNER"
    username = "admin"
    groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
}

node_groups = {
  spot = {
    use_name_prefix                 = true
    launch_template_use_name_prefix = true
    description                     = "SPOT instances"
    name                            = "jpn-automation-spot"
    iam_role_name                   = "jpn-automation-spot-"
    instance_types                  = ["t3.large", "t2.large"]
    capacity_type                   = "SPOT"
    subnet_ids = [
      "subnet-06b6f68878d1c52aa",
      "subnet-0ea3a984379b2eedf"
    ]
    min_size     = 1
    max_size     = 4
    desired_size = 2

    launch_template_tags = {
      ApplicationID = "APP3001241",
      Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
      Project       = "CICD",
      Country       = "Japan",
      Environment   = "DEV"
    }
  }
}

domain_info = {
  domain_name               = "automation.preprod.jp.amway.net"
  subject_alternative_names = ["*.automation.preprod.jp.amway.net"]
  route53_zone              = "automation.preprod.jp.amway.net"
  txtOwnerId                = "Z0535437329PM8KXXW6KB"
}

github_config_url = "https://github.com/AmwayCommon"
