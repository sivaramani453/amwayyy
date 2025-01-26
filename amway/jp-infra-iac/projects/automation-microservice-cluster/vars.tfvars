default_tags = {
  ApplicationID = "APPXXXXXX",
  ClusterName   = "atm-ms-cluster",
  Contact       = "anik_barua@amway.com",
  Project       = "AJ_INFRA_POC",
  Country       = "Japan",
  Environment   = "DEV"
}

eks_cluster_config = {
  name    = "atm-ms-cluster"
  version = "1.27"
  vpc_id  = "vpc-0d1aa036eb0120566"
  subnet_ids = [
    "subnet-0ea3a984379b2eedf",
    "subnet-06b6f68878d1c52aa"
  ]
  security_group_ids      = []
  policy_arns             = []
  automation_account_root = "arn:aws:iam::492449516969:root"
  eks_auth_roles = [
    {
      rolearn  = "arn:aws:iam::492449516969:role/AWS-CDA-492449516969-OWNER"
      username = "admin"
      groups = [
        "system:masters"
      ]
    },
    {
      rolearn  = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy"
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
    name            = "automation-microservice-spot"
    iam_role_name   = "jpn-sandbox-spot-"
    instance_types = [
      "t3.medium",
      "t3a.medium"
    ]
    capacity_type = "SPOT"
    subnet_ids = [
      "subnet-0ea3a984379b2eedf",
      "subnet-06b6f68878d1c52aa"
    ]
    min_size     = 1
    max_size     = 5
    desired_size = 5
    k8s_labels = {
      role = "workers"
    }
    launch_template_tags = {
      ApplicationID = "APPXXXXXX",
      Contact       = "anik_barua@amway.com",
      Project       = "AJ_INFRA_POC",
      Country       = "Japan",
      Environment   = "DEV"
    }
  }
}

domain_info = {
  route53_zone = "automation.preprod.jp.amway.net"
  txtOwnerId   = "Z0535437329PM8KXXW6KB"
}

nginx_ingress_info = {
  domain_name = "automation-microservice.automation.preprod.jp.amway.net"
  subject_alternative_names = [
    "*.automation-microservice.automation.preprod.jp.amway.net"
  ]
}

jaeger_dns_info = {
  domain_name = "jaeger.automation-microservice.automation.preprod.jp.amway.net"
  subject_alternative_names = [
    "*.jaeger.automation-microservice.automation.preprod.jp.amway.net"
  ]
}


