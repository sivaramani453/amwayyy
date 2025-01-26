resource "aws_security_group" "k8s_access_to_nodes" {
  name_prefix = "${var.name}-access-to-nodes"
  vpc_id      = var.vpc_id
}

module "cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                    = var.name
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    //    vpc-cni = {
    //      most_recent = true
    //    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  cluster_enabled_log_types = []

  cluster_additional_security_group_ids = [aws_security_group.k8s_access_to_nodes.id]

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.subnet_ids
  create_iam_role          = false
  iam_role_arn             = var.eks_role_arn
  #create_aws_auth_configmap = true
  #manage_aws_auth_configmap = true
  #aws_auth_roles            = var.eks_auth_roles
  enable_irsa = false

  cluster_security_group_additional_rules = {
    https_from_amway = {
      description = "HTTPS from Amway 10.0.0.0/8"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["10.0.0.0/8"]
    }
  }

  eks_managed_node_group_defaults = {
    instance_types  = ["t3.medium", "t2.medium"]
    use_name_prefix = true

    iam_role_additional_policies = {
      AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      CloudWatchLogsFullAccess           = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
      CloudWatchAgentServerPolicy        = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      AmazonDynamoDBFullA                = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
      AmazonElastiCacheFullAccess        = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
      AutoScalingFullAccess              = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
    }

    launch_template_tags = merge(var.default_tags,
      {
        SEC-INFRA-14 = "Latest90Days"
        ITAM-SAM     = "Appliance"
      }
    )
  }

  eks_managed_node_groups = var.node_groups
  cluster_tags            = var.eks_extra_tags
}


output "cluster" {
  value = module.cluster
}
