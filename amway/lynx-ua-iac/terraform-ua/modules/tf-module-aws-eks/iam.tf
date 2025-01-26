data "aws_iam_policy_document" "external-dns-policy" {
  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "external-dns-policy" {
  count = var.deploy_external_dns ? 1 : 0

  name   = "${var.project}-${var.environment}-external-dns-policy"
  policy = data.aws_iam_policy_document.external-dns-policy.json
}

resource "aws_iam_role_policy_attachment" "external-dns-policy" {
  count = var.deploy_external_dns ? 1 : 0

  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.external-dns-policy[0].arn
}

data "aws_iam_policy_document" "k8s-autoscaler" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeLaunchConfigurations",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "k8s-autoscaler" {
  name   = "${var.project}-${var.environment}-k8s-autoscaler-policy"
  policy = data.aws_iam_policy_document.k8s-autoscaler.json
}

resource "aws_iam_role_policy_attachment" "k8s-autoscaler" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.k8s-autoscaler.arn
}

data "aws_iam_policy_document" "aws-alb-ingress" {
  statement {
    effect = "Allow"

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "cognito-idp:DescribeUserPoolClient",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "tag:GetResources",
      "tag:TagResources",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "waf:GetWebACL",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "aws-alb-ingress" {
  name   = "${var.project}-${var.environment}-aws-alb-ingress-policy"
  policy = data.aws_iam_policy_document.aws-alb-ingress.json
}

resource "aws_iam_role_policy_attachment" "aws-alb-ingress" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.aws-alb-ingress.arn
}

data "aws_iam_policy_document" "ebs" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:AttachVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot",
      "ec2:DeleteTags",
      "ec2:DeleteVolume",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ebs" {
  name   = "${var.project}-${var.environment}-ebs-policy"
  policy = data.aws_iam_policy_document.ebs.json
}

resource "aws_iam_role_policy_attachment" "ebs" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.ebs.arn
}

data "aws_iam_policy_document" "efs" {
  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:*",
      "ec2:DescribeSubnets",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:DescribeNetworkInterfaceAttribute",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "efs" {
  name   = "${var.project}-${var.environment}-efs-policy"
  policy = data.aws_iam_policy_document.efs.json
}

resource "aws_iam_role_policy_attachment" "efs" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.efs.arn
}

