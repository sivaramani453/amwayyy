data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${data.aws_eks_cluster.cluster.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = data.aws_eks_cluster.cluster.name
  node_group_name = var.name
  node_role_arn   = var.node_group_iam_role
  subnet_ids      = var.subnet_ids
  capacity_type   = var.capacity_type

  version         = data.aws_eks_cluster.cluster.version
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  scaling_config {
    desired_size = var.scaling_config.desired_size
    min_size     = var.scaling_config.min_size
    max_size     = var.scaling_config.max_size
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

}

output "role" {
  value = aws_eks_node_group.node_group
}
