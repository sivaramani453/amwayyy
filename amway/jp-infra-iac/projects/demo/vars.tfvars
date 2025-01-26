default_tags = {
  ApplicationID = "APP3001178",
  Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
  Project       = "CICD",
  Country       = "Japan",
  Environment   = "DEV"
}

eks_cluster_config = {
  name    = "demo"
  version = "1.27"
  vpc_id  = "vpc-0d1aa036eb0120566" #### Premade VPC in the AUTOMATION PREPROD account
  subnet_ids = [
    "subnet-06b6f68878d1c52aa",
    "subnet-0ea3a984379b2eedf"
  ]
  security_group_ids      = []
  policy_arns             = []
  automation_account_root = "arn:aws:iam::492449516969:root"
  eks_auth_roles = [{
    rolearn  = "arn:aws:iam::492449516969:role/AWS-CDA-492449516969-OWNER" ## Allow the OWNER role to access EKS
    username = "admin"
    groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy" ## Allow the deploy IAM role to access EKS
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
}

## Here we define the node group with a single SPOT instsance
node_groups = {
  spot = {
    use_name_prefix                 = true
    launch_template_use_name_prefix = true
    description                     = "SPOT instances"
    name                            = "demo-spot"
    iam_role_name                   = "demo-spot-"
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
      ApplicationID = "APP3001178",
      Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
      Project       = "CICD",
      Country       = "Japan",
      Environment   = "DEV"
    }
  }
}

## We will run this cluster under the domain below
domain_info = {
  domain_name               = "demo.automation.preprod.jp.amway.net"
  subject_alternative_names = ["*.demo.automation.preprod.jp.amway.net"]
  route53_zone              = "automation.preprod.jp.amway.net"
  txtOwnerId                = "Z0535437329PM8KXXW6KB"
}
