# # Resource: aws_iam_role
# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# resource "aws_iam_role" "demo" {
#   name = "eks-cluster-demo"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# # Resource: aws_iam_role_policy_attachment
# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

# Resource: aws_eks_cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
data aws_ssm_parameter "eks_ami_release_version" {
    name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
  vpc_config {
    subnet_ids              = [aws_subnet.private-subnet-1a.id, aws_subnet.private-subnet-1b.id, aws_subnet.private-subnet-1c.id]
    #security_group_ids      = [aws_security_group.eks-cluster-sg.id]
    endpoint_private_access = false
    endpoint_public_access  = true
  }
  enabled_cluster_log_types = ["api", "audit"]
  role_arn                  = aws_iam_role.eks-cluster-role.arn
  version                   = var.k8_version
  tags                      = {
    Name = "${var.env}-eks-cluster"
  }
}


############### Nodes #######################


resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.env}-eks-worker-node"
  node_role_arn   = aws_iam_role.eks-worker-role.arn
  subnet_ids      = [aws_subnet.private-subnet-1a.id, aws_subnet.private-subnet-1b.id, aws_subnet.private-subnet-1c.id]
  ami_type       = "AL2_x86_64"
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  capacity_type  = "SPOT"  # ON_DEMAND, SPOT
  disk_size      = 10
  instance_types = [var.eks_worker_node_instance_type]
  tags                      = {
    Name = "${var.env}-eks-cluster-ng"
  }
  scaling_config {
    desired_size = var.desired_worker_node
    max_size     = var.max_worker_node
    min_size     = var.min_worker_node
  }

  update_config {
    max_unavailable = var.max_unavailable_node
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-role-nodepolicy,
    aws_iam_role_policy_attachment.eks-worker-role-cnipolicy,
    aws_iam_role_policy_attachment.eks-worker-role-servicepolicy,
    aws_iam_role_policy_attachment.eks-worker-role-containerregistry,
    aws_iam_role_policy_attachment.eks-worker-role-AmazonSSMFullAccess,
    aws_iam_role_policy_attachment.eks-worker-role-AdministratorAccess,
    aws_iam_role_policy_attachment.eks-worker-role-AmazonEC2RoleforSSM,
    aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy
  ]
}

