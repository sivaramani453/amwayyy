default_tags = {
  ApplicationID = "APPXXXXXX",
  Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
  Project       = "AJ_INFRA_POC",
  Country       = "Japan",
  Environment   = "DEV"
}

eks_cluster_config = {
  name    = "jpn-sandbox"
  version = "1.27"
  vpc_id  = "vpc-e0dcae85"
  subnet_ids = [
    "subnet-0dc805700ea636b09",
    "subnet-0e76b5e1a064b7500"
  ]
  security_group_ids      = []
  policy_arns             = []
  automation_account_root = "arn:aws:iam::417642731771:root"
  eks_auth_roles = [
    {
      rolearn  = "arn:aws:iam::417642731771:role/AWS-CDA-417642731771-CONTRIB"
      username = "admin"
      groups = [
        "system:masters"
      ]
    },
    {
      rolearn  = "arn:aws:iam::417642731771:role/AWS-CDA-417642731771-OWNER"
      username = "admin"
      groups = [
        "system:masters"
      ]
    }
  ]
}

node_groups = {
  spot = {
    use_name_prefix = true
    description     = "SPOT instances For Infra"
    name            = "jpn-sandbox-spot"
    iam_role_name   = "jpn-sandbox-spot-"
    instance_types = [
      "t2.medium",
      "t3.medium"
    ]
    capacity_type = "SPOT"
    subnet_ids = [
      "subnet-0dc805700ea636b09",
      "subnet-0e76b5e1a064b7500"
    ]
    min_size     = 1
    max_size     = 6
    desired_size = 6
    k8s_labels = {
      role = "workers"
    }
    launch_template_tags = {
      ApplicationID = "APPXXXXXX",
      Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
      Project       = "AJ_INFRA_POC",
      Country       = "Japan",
      Environment   = "DEV"
    }
  }
}

domain_info = {
  route53_zone = "preprod.jp.amway.net"
  txtOwnerId   = "Z3QFNC4QATXZ4Z"
}

nginx_ingress_info = {
  domain_name = "jpn-sandbox.preprod.jp.amway.net"
  subject_alternative_names = [
    "*.jpn-sandbox.preprod.jp.amway.net"
  ]
}

jaeger_dns_info = {
  domain_name = "jaeger.jpn-sandbox.preprod.jp.amway.net"
  subject_alternative_names = [
    "*.jaeger.jpn-sandbox.preprod.jp.amway.net"
  ]
}


